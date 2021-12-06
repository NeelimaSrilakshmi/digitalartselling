pragma solidity 0.8.6;

import "https://github.com/0xcert/ethereum-erc721/blob/master/src/contracts/tokens/nf-token-metadata.sol";
import "https://github.com/0xcert/ethereum-erc721/blob/master/src/contracts/tokens/nf-token-enumerable.sol";
import "https://github.com/0xcert/ethereum-erc721/blob/master/src/contracts/ownership/ownable.sol";
import "https://github.com/0xcert/ethereum-erc721/blob/master/src/contracts/utils/erc165.sol";

interface Royalties {
    function royaltyArt(
      uint256 tokenId, 
      uint256 value)
        external
        view
        returns (address _artist, uint256 _royaltyAmount);
}

abstract contract RoyaltiesperToken is ERC165, Royalties {


    struct ArtistRoy {
        address artist;
        uint256 royval;
    }

    mapping(uint256 => ArtistRoy) internal ArtistRoys; 

    function _setTokenRoyalty(
    uint256 id, 
    address artist,
    uint256 amount) 
    internal 
    {
        require(amount < 10001, 'ERC2981Royalties is high');
        ArtistRoys[id] = ArtistRoy(artist, amount);
    }


    function royaltyArt(
      uint256 tokenId, 
      uint256 value)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount){
          ArtistRoy memory royalty = ArtistRoys[tokenId];
          return (royalty.artist, (value * royalty.royval) / 10000);
    }
}

contract digitalToken is NFTokenEnumerable, NFTokenMetadata, Ownable, RoyaltiesperToken{

    constructor(string memory _name,string memory _symbol){
      nftName = _name;
      nftSymbol = _symbol;
    }

  function mint( address owner, uint256 tokenId, string calldata _uri, address artist, uint256 artistShare) external onlyOwner
  {
    super._mint(owner, tokenId);
    super._setTokenUri(tokenId, _uri);
    
    if (artistShare > 0) {
        _setTokenRoyalty(tokenId, artist, artistShare);
    }
    
  }


  function burn( uint256 tokenId) external onlyOwner{
    super._burn(tokenId);
  }

  function setTokenUriX(uint256 tokenId, string calldata _uri) external onlyOwner{
    super._setTokenUri(tokenId, _uri);
  }

  function _mint(address owner, uint256 tokenId) internal
    override(NFToken, NFTokenEnumerable)
    virtual
  {
    NFTokenEnumerable._mint(owner, tokenId);
  }


  function _burn( uint256 tokenId)
    internal
    override(NFTokenMetadata, NFTokenEnumerable)
    virtual
  {
    NFTokenEnumerable._burn(tokenId);
    if (bytes(idToUri[tokenId]).length != 0)
    {
      delete idToUri[tokenId];
    }
  }

  function _removeNFToken(address from, uint256 tokenId )
    internal
    override(NFToken, NFTokenEnumerable)
  {
    NFTokenEnumerable._removeNFToken(from, tokenId);
  }


  function _addNFToken(address owner, uint256 tokenId)
    internal
    override(NFToken, NFTokenEnumerable)
  {
    NFTokenEnumerable._addNFToken(owner, tokenId);
  }


  function _getOwnerNFTCount(address owner)
    internal
    override(NFToken, NFTokenEnumerable)
    view
    returns (uint256)
  {
    return NFTokenEnumerable._getOwnerNFTCount(owner);
  }

}
