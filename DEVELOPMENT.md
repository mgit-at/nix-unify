# Development

## Setup

You need incus installed

Following nixos config is recommended:

```nix
{
  virtualisation.incus.enable = true;
  networking.nftables.enable = true;
  networking.firewall.trustedInterfaces = [ "incusbr0" "incusbr1" ];
  users.users.YOU.extraGroups = [ "incus-admin" ];
}
```

Then you can init incus: `sudo incus admin init --minimal`

## Testing

- `bash test/incus-test-setup.sh`: Create containers for testing
- `bash test/test-deployment.sh`: Deploy example.nix on all containers

## Automated tests

If you want to run the full testsuite first run `EXPORT_IMAGE=1 bash test/incus-test-setup.sh` to create images from instances then `bash test/test-all.sh` to run the testsuite

## Notes

Write idempotent code. Tracking migration state is good, idempotent migrations are better.

Also consider implications about tracking of state changes
and subsequent removal of state changes once they should cease to exist.
