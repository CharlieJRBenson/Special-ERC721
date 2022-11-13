# Special Function ERC721A

- Live ETH (Settable USD price) Mint Price Updates (Chainlink Feed),
- Transfer Pausable.
- Transfer+Mint Pausable.
- Whitelistable.
- URI Update.
- Token Creation Metadata.
- Set Max supply.
- Set USD NFT value (Purchased w/ ETH).
- Multi-Sig Compatible withdraw function. (Settable Treasury Address)

# Import Dependencies Documentation for Future DevWork (IMPORTANT)

### _Author: Charlie Benson_

## EquityForSpectrum.sol

local imports:

```
import "./extensions/ERC721AQueryable.sol";
```

npm imports:

```
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
```

## ./extensions/ERC721AQueryable.sol

local imports:

```
import './IERC721AQueryable.sol';
import '../ERC721A.sol';
```

## ../ERC721A.sol

local imports:

```
import './IERC721A.sol';
import './Transferable.sol';
```

# Explanation

All ERC721A contracts and interfaces are exact copies of the npm dependency "erc721a/contracts/".
With EXCEPTION that "ERC721A.sol" is altered to inherit contract "Transferable.sol" to allow for the `whenTransferable` modifier and `whenNotPaused` modifiers to co-exist.
This allows for all transfers and mints to be paused using openzeppelin "Pausable" dependency, and allows for all transfers except minting to be Pausable using my "Transferable" dependency.
