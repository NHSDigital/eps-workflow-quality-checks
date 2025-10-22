# Multi-Architecture Docker Images (Separate Build Approach)

This workflow builds multi-architecture Docker images by combining separate architecture-specific builds. This approach is more efficient than cross-compilation when you have native runners for each architecture.

## How It Works

### 1. Separate Architecture Builds
- **`build_dev_container_x64`**: Builds on `ubuntu-22.04` (native x64)
- **`build_dev_container_arm64`**: Builds on `ubuntu-22.04-arm` (native ARM64)

Each job:
1. Builds the Docker image natively for its architecture
2. Pushes it to ECR with an architecture-specific tag (e.g., `:v1.0.0-amd64`, `:v1.0.0-arm64`)

### 2. Multi-Architecture Manifest Creation
- **`create_multi_arch_manifest`**: Combines both images into a multi-arch manifest
- Uses `docker buildx imagetools create` to create a manifest list
- Creates both versioned tag (`:v1.0.0`) and `:latest` tag

## Usage

### To Build and Push Multi-Architecture Images

Call the workflow with both required inputs:

```yaml
uses: ./.github/workflows/quality-checks.yml
with:
  dev_container_ecr: "your-repo-name"
  dev_container_image_tag: "v1.0.0"
  asdfVersion: "v0.10.2"
secrets:
  CLOUD_FORMATION_DEPLOY_ROLE: ${{ secrets.CLOUD_FORMATION_DEPLOY_ROLE }}
```

This will:
1. Build x64 image → push as `:v1.0.0-amd64`
2. Build ARM64 image → push as `:v1.0.0-arm64`  
3. Create manifest combining both → available as `:v1.0.0` and `:latest`

### To Skip Multi-Architecture Build

Call without ECR inputs to skip the container builds entirely:

```yaml
uses: ./.github/workflows/quality-checks.yml
with:
  asdfVersion: "v0.10.2"
```

## What Users Get

Users can pull with a single command:
```bash
docker pull 123456789012.dkr.ecr.eu-west-2.amazonaws.com/your-repo:v1.0.0
```

Docker automatically serves:
- `:v1.0.0-amd64` for Intel/AMD x64 systems
- `:v1.0.0-arm64` for ARM64 systems (Apple Silicon, ARM servers)

## Benefits of This Approach

✅ **Faster builds**: Native compilation is much faster than cross-compilation  
✅ **Parallel execution**: Both architectures build simultaneously  
✅ **Automatic platform detection**: Users get the right architecture transparently  
✅ **Conditional execution**: Only runs when ECR inputs are provided  
✅ **Security scanning**: Includes ECR vulnerability scanning  
✅ **Verification**: Confirms multi-arch manifest was created correctly

## Architecture Flow

```
┌─────────────────┐    ┌─────────────────┐
│ build_x64       │    │ build_arm64     │
│ (ubuntu-22.04)  │    │ (ubuntu-22.04-  │
│                 │    │  arm)           │
│ Build & Push    │    │ Build & Push    │
│ :tag-amd64      │    │ :tag-arm64      │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          └──────────┬───────────┘
                     │
        ┌────────────▼────────────┐
        │ create_multi_arch_      │
        │ manifest                │
        │ (ubuntu-22.04)          │
        │                         │
        │ Combine into:           │
        │ :tag (multi-arch)       │
        │ :latest (multi-arch)    │
        └─────────────────────────┘
```

## Verification

After the workflow completes, you can verify the multi-architecture manifest:

```bash
# Check the manifest
docker buildx imagetools inspect 123456789012.dkr.ecr.eu-west-2.amazonaws.com/your-repo:v1.0.0

# Should show both architectures:
Name:      123456789012.dkr.ecr.eu-west-2.amazonaws.com/your-repo:v1.0.0
MediaType: application/vnd.docker.distribution.manifest.list.v2+json
           
Manifests: 
  Name:      ...your-repo:v1.0.0@sha256:...
  MediaType: application/vnd.docker.distribution.manifest.v2+json
  Platform:  linux/amd64
             
  Name:      ...your-repo:v1.0.0@sha256:...
  MediaType: application/vnd.docker.distribution.manifest.v2+json
  Platform:  linux/arm64
```

## Technical Details

- **Job Dependencies**: `create_multi_arch_manifest` waits for both build jobs via `needs:`
- **Conditional Execution**: All container jobs only run when ECR inputs are provided
- **AWS Authentication**: Each job authenticates separately to AWS
- **Build Tools**: Uses Docker Buildx imagetools for manifest creation
- **Security**: 30-second delay before scanning allows ECR to process new images
