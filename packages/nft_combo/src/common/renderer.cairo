use crate::common::encoding::{Base64Encoder};
use graffiti::json::JsonImpl;
// use graffiti::{Tag, TagImpl};

#[derive(Drop)]
pub struct Attribute {
    pub key: ByteArray,
    pub value: ByteArray,
}

#[derive(Drop)]
pub struct TokenMetadata {
    pub token_id: u256,
    pub name: ByteArray,
    pub description: ByteArray,
    pub image: ByteArray,
    pub attributes: Span<Attribute>,
    pub additional_metadata: Span<Attribute>,
}

pub trait MetadataRendererTrait {
    fn render_token_metadata(metadata: TokenMetadata) -> ByteArray;
}

pub impl MetadataRenderer of MetadataRendererTrait {
    fn render_token_metadata(metadata: TokenMetadata) -> ByteArray {
        let json = JsonImpl::new()
            .add("id", format!("{}", metadata.token_id))
            .add("name", metadata.name)
            .add("description", metadata.description)
            .add("image", metadata.image)
            .add("metadata", MetadataHelper::_format_metadata(metadata.attributes, metadata.additional_metadata))
            .add_array("attributes", MetadataHelper::_create_traits_array(metadata.attributes));
        let result = json.build();
        (Base64Encoder::encode_json(result, false))
    }
}

#[generate_trait]
impl MetadataHelper of MetadataHelperTrait {
    fn _format_metadata(attributes1: Span<Attribute>, attributes2: Span<Attribute>) -> ByteArray {
        let mut json = JsonImpl::new();
        let mut n: usize = 0;
        while (n < attributes1.len()) {
            let attr: @Attribute = attributes1.at(n);
            json = json.add(attr.key.clone(), attr.value.clone());
            n += 1;
        };
        let mut n: usize = 0;
        while (n < attributes2.len()) {
            let attr: @Attribute = attributes2.at(n);
            json = json.add(attr.key.clone(), attr.value.clone());
            n += 1;
        };
        (json.build())
    }
    fn _create_traits_array(attributes: Span<Attribute>) -> Span<ByteArray> {
        let mut result: Array<ByteArray> = array![];
        let mut n: usize = 0;
        loop {
            if (n >= attributes.len()) { break; }
            let attr: @Attribute = attributes.at(n);
            let json = JsonImpl::new()
                .add("trait", attr.key.clone())
                .add("value", attr.value.clone());
            result.append(json.build());
            n += 2;
        };
        (result.span())
    }

}
