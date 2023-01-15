#!/usr/bin/env python3

import sys
import argparse
import numpy as np
import os


DESC = "Prints keys and values from model.npz file."

non_parameter_keys = ["special:model.yml"]


def main():
  args = parse_args()
  model = np.load(args.model)

  file_size=os.path.getsize(args.model)

  if args.key:
    if args.key not in model:
        print("Key not found")
        exit(1)
    else:
      print(model[args.key])
  else:
    objects=0
    parameters=0
    for key in (k for k in model if k not in non_parameter_keys):
      objects+=1
      parameters+=model[key].size
      if not args.summary:
        print(key, model[key].shape)

    # Summary
    parameters/=1e6
    file_size=np.ceil(file_size/1024**2)
    print(f"{args.model}: {objects} objects with a total of {parameters:.1f}M parameters; {file_size:.0f} MB")



def parse_args():
  parser = argparse.ArgumentParser(description="")
  parser.add_argument("-m", "--model",metavar='model.npz', help="model file", required=True)
  parser.add_argument("-k", "--key", help="print value for specific key")
  parser.add_argument("-s", "--summary", action="store_true",
                      help="only show summary")
  return parser.parse_args()


if __name__ == "__main__":
  main()
