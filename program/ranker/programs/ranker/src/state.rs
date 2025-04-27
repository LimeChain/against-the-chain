use anchor_lang::prelude::*;

#[account]
#[derive(InitSpace)]
pub struct Ranking {
    pub members: [Pubkey; 10],
}
