use anchor_lang::prelude::*;

use crate::Ranking;

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(init, payer = authority, space = 8 + Ranking::INIT_SPACE)]
    pub ranking: Account<'info, Ranking>,

    #[account(mut)]
    pub authority: Signer<'info>,
    pub system_program: Program<'info, System>,
}

pub fn initialize(ctx: &mut Context<Initialize>) -> Result<()> {
    ctx.accounts.ranking.members = [Pubkey::default(); 10];
    Ok(())
}
