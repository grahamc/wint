# When is now, then?

Take and send snapshots to a remote as quickly as possible, for
near-real-time, incremental replication for system state.

In one terminal:

```
mkfifo from-sender
mkfifo from-receiver
./when-is-now-then-sender.sh > from-sender < from-receiver
```

In another terminal:

```
./when-is-now-then-receiver.sh < from-sender > from-receiver
```

Only tested locally between two junk datasets. Biggest downside is
that if there is low IO, the loop is very fast and `zed` uses a ton of
CPU. I imagine it could save a lot of cycles if it checked to see if
the txg of the dataset changed before issuing a loop.
