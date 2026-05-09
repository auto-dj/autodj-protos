# autodj-protos

Single source of truth for all AutoDJ gRPC service definitions.

## Proto files

| File | Package | Server | Clients |
|------|---------|--------|---------|
| `proto/analyzer.proto` | `analyzer` | `analyzer` service | `dispenser` |
| `proto/chef.proto` | `chef` | `chef` service | `dashboard` |
| `proto/connector.proto` | `Connector` | `connector` service | `dispenser`, `chef` |
| `proto/trackprocessor.proto` | `trackprocessor` | `blender` service | `chef` |

## How services consume this repo

Each AutoDJ service includes this repo as a **git submodule** at `protos/`:

```bash
# Add the submodule (one-time setup per service repo)
git submodule add git@github.com:auto-dj/autodj-protos.git protos
git submodule update --init --recursive
```

Then generate stubs with the appropriate script for the service's language.

## Generating stubs

### TypeScript services (chef, dispenser, connector, dashboard)

```bash
# From the service root (requires grpc-tools + ts-proto in devDependencies)
make protos
# or directly:
bash protos/scripts/codegen-ts.sh src/generated/protos
```

Generated files land in `src/generated/protos/` (gitignored). Import as:

```typescript
import { ConnectorClient } from '../generated/protos/connector';
```

### Python service (analyzer)

```bash
# From the service root (requires grpcio-tools in venv)
make protos
# or directly:
bash protos/scripts/codegen-py.sh src/protos
```

### C++ service (blender)

CMake calls `scripts/codegen-cpp.sh` via a custom command during configuration. You can also run manually:

```bash
bash protos/scripts/codegen-cpp.sh build/generated/protos
```

## Updating the submodule to latest

Inside each service repo:

```bash
git submodule update --remote protos
git add protos
git commit -m "chore: bump autodj-protos to latest"
```

Or from the workspace root, use the helper:

```bash
make protos-bump   # walks all service repos and bumps protos submodule
```

## Adding a new RPC

1. Edit the relevant `.proto` file here.
2. Open a PR — name it clearly (e.g. `feat(connector): add SubscribeToVotes rpc`).
3. After merge, update the submodule in every consuming service (`make protos-bump`).
4. Run `make protos` in each service to regenerate stubs.
5. Update any adapter code that implements or calls the new RPC.

## Adding a new service proto

1. Create `proto/<service>.proto` with the appropriate `syntax`, `package`, `service`, and `message` blocks.
2. The codegen scripts pick up all `*.proto` files automatically — no script changes needed.
3. Document the new file in the table above.

## Gitignore in consuming services

Generated stubs should never be committed. Each service's `.gitignore` should contain:

```gitignore
src/generated/protos/
```

(Python keeps its generated files at `src/protos/` by convention; those `*_pb2*.py` files are also gitignored there.)
