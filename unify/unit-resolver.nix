{ config, lib }:

with lib;

let
  unitDependencyLookup = [ "requires" "wants" "after" "before" "bindsTo" "partOf" "conflicts" "requisite" ];
  empty = listToAttrs (map (k: (nameValuePair k [])) unitDependencyLookup);

  unitType = unit: elemAt (splitString "." unit) 1;
  unitName = unit: elemAt (splitString "." unit) 0;
  unitGet = unit: let
    t = config.systemd.${unitType unit + "s"};
    n = unitName unit;
  in
    # TODO: stricter check if it's "really an upstream unit"
    # (those we need to skip, they exist on the host anyways)
    if t ? ${n} then t.${n} else empty;

  visitUnit = alreadySeen: unit: let
    v = unitGet unit;
    links = concatMap (visit: v.${visit}) unitDependencyLookup;
  in [ unit ] ++ links ++
    (concatMap
      (unitToVisit: visitUnit (alreadySeen // { ${unit} = true; }) unitToVisit)
      (filter (u: !(alreadySeen ? ${u})) links)
    );
in

units: unique (concatMap (u: visitUnit {} u) units)
