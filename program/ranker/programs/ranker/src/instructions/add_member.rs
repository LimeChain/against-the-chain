use anchor_lang::prelude::*;

use crate::{error::ErrorCode, Ranking};

pub fn add_member(ctx: &mut Context<AddMember>, params: &AddMemberParams) -> Result<()> {
    let ranking = &mut ctx.accounts.ranking;
    require!(
        params.rank_position < ranking.members.len() as u8,
        ErrorCode::InvalidRankPosition
    );
    ranking.members[params.rank_position as usize] = params.member;
    Ok(())
}

#[derive(Accounts)]
pub struct AddMember<'info> {
    pub payer: Signer<'info>,
    pub ranking: Account<'info, Ranking>,
}

#[derive(AnchorDeserialize, AnchorSerialize, Clone)]
pub struct AddMemberParams {
    rank_position: u8,
    member: Pubkey,
}
