Large Scale Database Tests, Summer 2015
---------------------------------------

This repository contains:
- scripts to dump an appropriate subset of the Winter 2013 Stripe 82 data release
- scripts that take those dumps, index/duplicate to get to ~10% of the
  expected LSST DR1 release sizes, and load them into Qserv on IN2P3 cluster nodes.

The top-level data loading scripts should be run on `ccqservbuild.in2p3.fr`, and
make use of [ansible](https://github.com/ansible/ansible) to launch commands
on cluster nodes (via SSH). This is installed (with its dependencies) in
`/qserv/exp`; run `source /qserv/exp/env.sh` from a bash shell to bring it into
your environment.

The IN2P3 cluster uses Kereberos rather than SSH keys to go between ccqservbuild
and cluster nodes. If, like the author, you haven't used Kereberos before, be
aware that there appear to be some gotchas. In particular, Kereberos tickets seem
to expire after some period of inactivity (1 hour?).

Since the `load_XXX` scripts invoke ansible subcommands which take a very long
time (hours) to run, special measures must be taken to avoid ticket expiration
(and SSH connection failures for subsequent ansible commands).

I have been running as follows from inside screen:

    AKLOG=/bin/aklog krenew -K 15 -t -- sh -c './load_Object 2>&1 | tee ~/load_Object.log'

See the `krenew` man page for details, but this basically says to renew the ticket
for the given subsidiary command every 15 minutes.
