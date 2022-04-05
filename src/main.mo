import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Trie "mo:base/Trie";
import Types "./types";

actor {
    type Metadata = Types.Metadata;
    type Error = Types.Error;

    stable var artists : Trie.Trie<Principal, Metadata> = Trie.empty();
    stable var registryName : Text = "Artists registry";

    public query func name() : async Text {
        return registryName;
    };

    public query func get(canisterId : Principal) : async ?Metadata {

        Trie.find(
            artists,
            key(canisterId),
            Principal.equal
        );
        
    };

    public shared({caller}) func add(metadata : Metadata) : async Result.Result<(), Error> {

        if(Principal.isAnonymous(caller) or Principal.notEqual(caller, metadata.principal_id)) {
            return #err(#NotAuthorized);
        };

        let artist: Metadata = metadata;

        let (newArtists, existing) = Trie.put(
            artists,
            key(artist.principal_id),
            Principal.equal,
            artist
        );

        switch(existing) {
            // If there are no matches, add artist to registry
            case null {
                artists := newArtists;
                #ok(());
            };
            case (? v) {
                #err(#Unknown("Already exist"));
            };
        };
    };

    public shared({caller}) func remove(principal: Principal) : async Result.Result<(), Error> {

        if(Principal.notEqual(caller, principal) or Principal.isAnonymous(caller)) {
            return #err(#NotAuthorized);
        };

        let result = Trie.find(
            artists,
            key(principal),
            Principal.equal,
        );

        switch(result) {
            // No matches
            case null {
                #err(#NonExistentItem);
            };
            case (? v) {
                artists := Trie.replace(
                    artists,           // Target trie
                    key(principal),     // Key
                    Principal.equal,   // Equality checker
                    null
                ).0;
                #ok(());
            };
        };
    };

    private func key(x : Principal) : Trie.Key<Principal> {
        return { key = x; hash = Principal.hash(x) }
    };
};
