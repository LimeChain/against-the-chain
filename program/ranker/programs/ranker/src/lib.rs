pub mod constants;
pub mod error;
pub mod instructions;
pub mod state;

use anchor_lang::prelude::*;

pub use constants::*;
pub use instructions::*;
pub use state::*;

declare_id!("3yXsSqtkb411cutMyU8e4PVK2izqYWN9hVaNckkjgBVk");

#[program]
pub mod ranker {
    use super::*;

    pub fn initialize(mut ctx: Context<Initialize>) -> Result<()> {
        instructions::initialize(&mut ctx)
    }

    pub fn add_member(mut ctx: Context<AddMember>, params: AddMemberParams) -> Result<()> {
        instructions::add_member(&mut ctx, &params)
    }
}
