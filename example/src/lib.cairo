mod systems {
    pub mod actions;
    pub mod character;
    pub mod cash;
    pub mod components {
        pub mod coin_component;
        pub mod token_component;
    }
}

mod models {
    pub mod coin_config;
    pub mod token_config;
}

mod libs {
    pub mod store;
    pub mod dns;
}

#[cfg(test)]
mod tests {
    pub mod test_cash;
    pub mod test_character;
    pub mod test_world;
    pub mod utils;
}
