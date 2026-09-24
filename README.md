# Lab 0 — Environment & Toolchain Warm-up

**SDNFV (CSIC30127), 115-1 — NYCU Institute of Network Engineering**

> **This lab does not count toward your grade.** It is a *gate*: you must get all
> five checks green before Lab 1. Its only job is to make sure that (a) your
> toolchain works, and (b) you can drive `git`, `make` and `docker` without
> fighting them for the rest of the semester.
>
> **You may use AI tools for this lab.** You are still responsible for being able
> to explain every line you submit.

---

## 1. What you are building

A single container that can run [Mininet](http://mininet.org/) on top of
[Open vSwitch](https://www.openvswitch.org/), plus a two-then-three host topology
that forwards traffic **with no SDN controller at all**.

```
        ┌──────────────── container "lab0" ────────────────┐
        │  ovsdb-server + ovs-vswitchd (userspace datapath) │
        │                                                   │
        │        h1 ── s1 ── h2          (part A)           │
        │              │                                    │
        │              h3                (part B)           │
        └───────────────────────────────────────────────────┘
```

`s1` runs in **`failMode=standalone`**, which makes OVS behave like an ordinary
learning L2 switch when no controller is connected. This is deliberately the
*opposite* of what you will do from Lab 2 onwards, where a controller you wrote
installs every flow. Lab 0 is your "before" picture.

## 2. What you have to change

Exactly **two files**:

| File | What to do |
| --- | --- |
| `docker-compose.yml` | Four `TODO` comments. The container as shipped cannot run Mininet. Fix it. |
| `topo/lab0_topo.py` | One `TODO`. Add the third host `h3` and its link to `s1`. |

Everything else — `Dockerfile`, `Makefile`, `tests/` — is given and **must not be
modified**. Editing the tests to make them pass is an academic integrity
violation; the autograder runs from a clean checkout anyway, so it gains you
nothing.

**Protected-file integrity is a whole-lab gate:** any mismatch yields **0/100**,
not merely a loss of 5 or 10 policy points. An obsolete protected starter revision
can also trigger this gate. Run `make update` and merge its local update branch;
do not edit the protected files or their hashes.

## 3. How to work

Use a Linux VM that you administer as the **Docker engine host**. In the course
environment this means the assigned lab VM, not the Proxmox/PVE hypervisor.
This lab uses the OVS userspace datapath and does not require an OVS kernel
module or BBR, but the Docker engine still needs the shared course resource
limits.

Run the non-scoring preflight before starting the lab:

```bash
make check-update
make pretest
```

`make pretest` only diagnoses the current Docker engine; it is deliberately
separate from `make test`. If it reports that host preparation is required,
follow the exact repair and persistence instructions in the generated
[Golden runtime guide](.github/golden/README.md). Do not run host preparation
on PVE or on any shared/remote Docker engine without its administrator's
authorization.

```bash
make build      # build the image
make up         # start the container
make test       # run all five checks
make shell      # drop into the container to poke around
make logs       # container logs, when something refuses to start
make clean      # tear everything down
```

Run `make test` locally until it is green, then push. Every push re-runs the
same five checks on GitHub Actions, and GitHub Classroom shows you the result.
For an explicitly offline checkpoint or viva, use `make test-offline`: it runs
the same integrity policy and lab checks, with a notice that remote freshness is
**not** checked. This is a deliberate local mode, never a fallback for a failed
online check; official grading still enforces canonical files and metadata.

### Keep your lab up to date

Updates are **manual**: publication does not open update PRs, send proactive
update notifications, or rewrite accepted repositories. Run `make check-update`
regularly and before submitting; do not wait for an instructor update PR.
If an older integrity diagnostic mentions a PR, use its `make update` alternative.

Install Python 3 on the Docker engine VM as well as Git, Make, and Docker.
`make test` first checks the public template's latest release. A required update
stops the command; a newer optional release only prints a notice. If the network
or release metadata cannot be read, the check fails explicitly: fix the connection
and retry `make check-update`, rather than assuming the checkout is current.
`make up` does not contact the release server. Grading checks the canonical
release metadata hashes without relying on a network freshness request.

Run `make update` after committing or stashing **all** work, including untracked
files. It applies the difference between your old and new immutable template tags
with a three-way merge on a new `instructor/update-<tag>` branch, preserving your
exercise edits and Classroom configuration. It commits using your Git identity
but never pushes. Review the result, then follow the printed commands to
fast-forward your original branch; run `make test`, then push that branch to
`origin` to resubmit. If you work on a separate feature branch, also merge it
into your Classroom repository's default branch and push that branch. Leaving
the update on its dedicated local branch does not update your submission.

If an update conflicts, it stops on the update branch without making a commit.
Use `git status`, resolve the conflicts while keeping your work, then stage and
commit the resolution before merging the branch. Do not rerun the update over an
existing update branch. The error also explains how to abandon the staged update
and return to your original commit. If `.lab-release.json` is missing, ask your
instructor to migrate the legacy repository; do not invent or edit release
metadata. That metadata is integrity-protected by grading; the local freshness
check alone is not the grader's trust mechanism.

### If you are new to any of these

You are expected to close these gaps yourself — the rest of the course assumes
them:

- **git** — <https://git-scm.com/book/en/v2> (ch. 2–3 is enough)
- **make** — <https://www.gnu.org/software/make/manual/make.html> (§2 "An Introduction to Makefiles")
- **docker compose** — <https://docs.docker.com/compose/compose-file/>
- **Mininet** — <http://mininet.org/walkthrough/> and the
  [Python API intro](https://github.com/mininet/mininet/wiki/Introduction-to-Mininet)
- **Open vSwitch** — <https://docs.openvswitch.org/en/latest/faq/>

## 4. The five checks

| # | Check | What it is really testing |
| --- | --- | --- |
| 1 | `tests/00_env.sh` | The container is named `lab0`, is running, has `mn` / `ovs-vsctl` / `python3`, and **can see this repository** from the inside. |
| 2 | `tests/10_ovs.sh` | `ovsdb-server` and `ovs-vswitchd` are alive inside the container, and a `netdev` (userspace) bridge can actually be created. |
| 3 | `tests/20_ping.sh` | `topo/lab0_topo.py` builds and `h1` can ping `h2` through `s1` with no controller. |
| 4 | `tests/30_pingall.sh` | With `h3` added, `pingall` reports **0% dropped**. |
| 5 | `tests/40_git.sh` | You made at least 3 commits of your own, there is a `.gitignore`, and no build junk (`__pycache__`, `*.pyc`, `.env`, `*.log`) is committed. |

## 5. Two things that will bite you

1. **Mininet needs privileges that a default container does not have.** It creates
   network namespaces and `veth` pairs. Read the error message you get before you
   start guessing — it tells you what is missing.
2. **We use the OVS *userspace* datapath, not the kernel one.** This keeps the
   exercise independent of host kernel modules and gives the same forwarding
   model on the supported Docker engine VMs and the autograder. `lab0_topo.py`
   already requests the userspace datapath; do not "fix" it back to kernel just
   because a kernel datapath is available on your machine. Ask yourself what
   that difference costs in performance — you will measure it in a later lab.

3. **"Works on my laptop" is not the same as "works on the autograder."** If you take
   the surgical `cap_add` route in TODO 2, remember that Linux has *two* independent
   layers here: **capabilities** (what `cap_add` grants) and **LSM / AppArmor** (a
   mandatory-access-control layer sitting on top of them). Docker applies a default
   AppArmor profile that blocks the `mount` calls Mininet needs when it builds a
   network namespace — even with `SYS_ADMIN`. Docker Desktop on Windows/macOS runs
   inside a LinuxKit VM with **no AppArmor at all**, so you will never see this
   locally; the autograder runs on an Ubuntu host where AppArmor **is** enabled.
   `privileged: true` happens to switch off both layers at once, which is exactly
   why the blunt answer "just works" and the surgical one needs one more line:

   ```yaml
   security_opt:
     - apparmor:unconfined
   ```

   `make up` now checks this for you and says so, instead of letting the ping tests
   sit there until they time out. Be ready to explain this difference in Lab 1 — it
   is a good example of why "it ran on my machine" is not evidence.

## 6. Submission

Push to your Classroom repository. There is nothing to hand in on E3 for Lab 0.
Your last push before the Lab 1 deadline is what counts.
