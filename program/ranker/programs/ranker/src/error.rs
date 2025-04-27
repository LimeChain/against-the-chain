use anchor_lang::prelude::*;

#[error_code]
pub enum ErrorCode {
    #[msg("Invalid rank position")]
    InvalidRankPosition,
    #[msg("Invalid token account")]
    InvalidTokenAccount,
    #[msg("Invalid metadata account")]
    InvalidMetadataAccount,
    #[msg("Invalid master edition account")]
    InvalidMasterEdition,
}
