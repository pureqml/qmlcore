#!/usr/bin/env python

# https://medium.com/@mshockwave/using-llvm-lit-out-of-tree-5cddada85a78

# To run lit-based test suite:
# cd xyz/qmlcore/test && ./lit.py -va .

from lit.main import main
import os

if __name__ == '__main__':
    if not os.path.exists(".cache/core.Item"):
        print("Note that first run may take quite a while .cache/core.* is populated...")
    main()
