import { BigInt, Bytes } from "@graphprotocol/graph-ts"
import {
  Buttpluggy,
  Approval,
  ApprovalForAll,
  Transfer
} from "../generated/Buttpluggy/Buttpluggy"
import { ButtpluggyNft, Owner } from "../generated/schema"


export function handleTransfer(event: Transfer): void {
  const tokenId = event.params._tokenId.toString();
  const userTo = event.params._to.toHexString();

  let nft = ButtpluggyNft.load(tokenId)
  if (!nft) {
    nft = new ButtpluggyNft(tokenId)
  }
  nft.owner = userTo
  nft.save()

  let owner = Owner.load(userTo)
  if (!owner) {
    owner = new Owner(userTo)
    owner.save()
  }
}
