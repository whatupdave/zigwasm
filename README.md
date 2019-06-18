# zig + wasm

Experimenting with zig web game development.

Check out its majesty: https://whatupdave.github.io/zigwasm/

# Run

In one tab run zig compiler on watch:

```
$ fswatch src/main.zig | while read f; do clear; zig build install --prefix web && echo $(date); done
```

In another tab start parcel to build web:

```
$ yarn start
```

The game should now be running at http://localhost:1234 and will auto reload if zig or javascript changes.
