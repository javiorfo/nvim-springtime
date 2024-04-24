# nvim-springtime
### A blazingly fast and custimizable Spring project creator
*Neovim plugin based on [Spring Initializr](https://start.spring.io) written in Lua and Rust*

## Caveats
- This plugin is made in Lua and Rust. So [Rust & Cargo](https://www.rust-lang.org/) must be installed.
- Extra dependencies must be installed required by rust crates, like: `libcurl, libclang, cmake` 
- This plugin has been developed on and for `Linux` following open source philosophy.

## Installation
`Packer`
```lua
use {
    'javiorfo/nvim-springtime',
    requires = {
        "javiorfo/nvim-popcorn",
        "javiorfo/nvim-spinetta",
        "hrsh7th/nvim-cmp"
    },
    run = function()
        require'springtime.core'.build()
    end,
}
```

`Lazy`
```lua
{ 
    'javiorfo/nvim-springtime',
    lazy = true,
    cmd = { "Springtime", "SpringtimeUpdate", "SpringtimeBuild" },
    dependencies = {
        "javiorfo/nvim-popcorn",
        "javiorfo/nvim-spinetta",
        "hrsh7th/nvim-cmp"
    },
    build = function()
        require'springtime.core'.build()
    end,
    opts = {
        -- If you want to change default configurations
        
    }
}
```


## Usage

### List of commands:
| Command | Description                       |
| -------------- | --------------------------------- |
| `:Springtime`  | This command will open Springtime |
| `:SpringtimeBuild` | This command will build Rust code with cargo and update the plugin (executing :SpringtimeUpdate inside) |
| `:SpringtimeLogs`   | This command will open a buffer with the generated plugin logs |
| `:SpringtimeUpdate` | This command will update the libraries and Spring settings |


## Troubleshooting and recommendations
- SpringtimeBuild problems
- SpringtimeUpdate every X time


## Screenshots

<img src="https://github.com/javiorfo/img/blob/master/nvim-springtime/springtime.gif?raw=true" alt="springtime" />

**NOTE:** The colorscheme **umbra** from [nvim-nyctophilia](https://github.com/javiorfo/nvim-nyctophilia) is used in this image

---


### Donate
- **Bitcoin** [(QR)](https://raw.githubusercontent.com/javiorfo/img/master/crypto/bitcoin.png)  `1GqdJ63RDPE4eJKujHi166FAyigvHu5R7v`
- [Paypal](https://www.paypal.com/donate/?hosted_button_id=FA7SGLSCT2H8G)
