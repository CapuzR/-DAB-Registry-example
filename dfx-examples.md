## Name

` dfx canister call DRS-example name `

## Add

` dfx canister call DRS-example add '(record {thumbnail="test"; name="test"; frontend=null; description="test"; details=vec {record {"test"; variant {Text="test"}}}; principal_id=principal "< principal >"})' `

## Get

` dfx canister call DRS-example get '(principal "< principal >")' `

## Remove

` dfx canister call DRS-example remove '(principal "< principal >")' `