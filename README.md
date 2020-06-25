# Mylabs

Mylabs is my personal labs

## Installation

Clone this repository

```bash
git clone htts://github.com/stootles/mylabs
```

## Usage

```shell
make help

bootstrap_vpc                  Prepare repository for use: will setup VPC and s3 for state
check                          Run any pre-commit tests you want outside of an acutal commit
fmt                            Formats the .tf files
init                           Install required tools for local hygene checks
plan                           You need to include the comment for help
tear_vpc_down                  Remove VPC and subnets

```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.