# Smart-contracts
## API
## ERC721 Token smart-contract (BTOT)
### Structure of token:
- serialNumber - serial number that token belongs to
- expirationTime - timestamp in seconds (GMT)
- price - IPO price that investor have to pay to buy this token
- profit - value that investor will get after token's expiration
- isPresented - this token is presented in mapping (set always as true, this is solidity specifics)
### setApprovalForAll - allow Bank Manager to freely work with your tokens without approvals
Is public

As address pass Bank Manager smart-contract's address, and as approved - true
***
args:

address spender - contract's address

bool approved - whether operator can tranfer tokens without approval
***
returns:

no return value
***
example:
["0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8", true]

### emitTokens - emit new tokens for selling
Can be executed only from owner wallet address.
***
args:

uint256 tokenId - id of the first token, that would be emitted

uint256 amount - number of tokens to emit

TokenListing data - token structure
***
returns:

reverted - one of the token ids is occupied
***
example:
[1, 4, [123223, 1683140580, 20, 25, true]]
### isExpired - check if token has expired 
Is public
***
args:

uint256 tokenId - id of the token you want to check
***
returns:

bool:
- true - token is expired
- false - token hasn't expired yet

reverted - token with such id doesn't exist
***
example:
[1]
### getPrice - returns purchase price for the investor
Is public
***
args:

uint256 tokenId - id of the token
***
returns:

uint256 - the price of token

reverted - token with such id doesn't exist
***
example:
[1]
### getProfit - returns selling price for the investor (is actual profit + initial price)
Is public
***
args:

uint256 tokenId - id of the token
***
returns:

uint256 - the profit from token

reverted - token with such id doesn't exist
***
example:
[1]
### getToken - get TokenListing object
Is public
***
args:

uint256 tokenId - id of the token
***
returns:

TokenListing - the token with passed id

reverted - token with such id doesn't exist
***
example:
[1]
## ERC20 Currency smart-contract (BTOC)
### mint - mint tokens to address
Can be executed only from owner wallet address.
***
args:

address to - wallet's address to which you want to mint

uint256 amount - number of tokens to emit
***
no return value
***
example:
["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", 100]
### increaseAllowance - allow Bank Manager spend more tokens
Is public

As address pass Bank Manager smart-contract's address, and as price total price that will be transferred between two addresses

Always invoke before buying
***
args:

address spender - contract's address

uint256 addedValue - allowed amount to spend
***
no return value
***
example:
["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", 100]
## BankManager

### constructor
args:

address currency - address of ERC20 smart-contract

address token - address of ERC721 smart-contract

### buyToken - buy batch of tokens
Is public

Function applies to all tokens in the interval
***
args:

uint256 startId - id of the first token (included)

uint256 endId - id of the last token (included)
***
returns:

reverted - right bound is less than left one

reverted - address that calls this function already owns token with one of the ids in given interval

reverted - payment price exceeds balance

reverted - payment price exceeds allowed amount to spend from wallet

reverted - didn't set allowance to transfer BTOT-s
***
example:
[1, 3]
### expireToken - sell batch of tokens (bank is buying back tokens from investors)
Can be executed only from owner wallet address.

Function applies to all tokens in the interval
***
args:

uint256 startId - id of the first token (included)

uint256 endId - id of the last token (included)
***
returns:

reverted - right bound is less than left one

reverted - address that calls this function already owns token with one of the ids in given interval

reverted - one of the tokens hasn't expired yet

reverted - payment price exceeds balance

reverted - payment price exceeds allowed amount to spend from wallet

reverted - didn't set allowance to transfer BTOT-s
***
example:
[1, 3]
