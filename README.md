# github_pulls.nvim

This simple plugin is for users to more easily track authored PRs and reviews requested for any github repo. 

## Use cases

- List all authored PRs for in a cwd github repo:

(add screenshot here)

- List all reviews requested for in a cwd github repo: 

(add screenshot here)

## Installation 

Packer: 
```lua
  use {
    'changangus/github_pulls.nvim',
    config = function()
      require('github_pulls').setup({
          username = 'YOUR_GH_USERNAME'
      })
    end
  }

```

## Setup

1. Create a github personal access token, instructions can be found [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) 

2. Globally export an environment variable named `GH-TOKEN` and assign your new token to the variable 

3. Make sure you have your username set in the config 

4. Create keymaps to call the functions: 

```lua
vim.keymap.set("n", "YOUR KEYMAP", ":lua require('github_pulls.ui').toggle_pr_menu()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "YOUR KEYMAP", ":lua require('github_pulls.ui').toggle_reviews_menu()<CR>", { noremap = true, silent = true })
```
