Memorandom
==

Memorandom provides a command-line utility and class library from extracting secrets from binary files. Common use cases include extracting encryption keys from memory dumps and identifying sensitive data stored in block devices.


Installation
--
    $ git clone https://github.com/rapid7/memorandom
    $ cd memorandom
    $ bundle install
    
Usage
--
    $ bin/memorandom.rb --help
    
    Usage: bin/memorandom.rb [options] file1 file2 ... fileN
    Extracts interesting data from binary files

    Options
        -p [plugin1,plugin2,plugin3...], Specify a list of plugin names to use, otherwise use all plugins
            --plugins
        -o, --output [directory]         Specify the directory in which to store found data
        -w, --window [number]            Specify the number of kilobytes to scan at once (default: 1024).
        -x, --overlap [number]           Specify the number of kilobytes to overlap between windows (default: 4).
        -l, --list-plugins               List all of the available plugins
        -h, --help                       Show this message.


Memorandom can search files, block devices, and standard input for interesting things and automatically extract and save these into the specified output directory (--output). This makes it useful for processing memory dumps, network traffic logs, hard disk images, or entire filesystems. 


Memorandom uses plugins to scan for specific types of data within the target files. By default, all plugins are enabled, which can lead to noisy output and slow scans. For small files, all plugins are usually fine, but when processing large amounts of data, it is better to limit the search to specific plugins.

The example below will only scan for PEM-encoded data in the target files

    $ bin/memorandom.rb -p pem ~/.ssh/*
    [+] file:/home/dev/.ssh/ec2.pem PEM@0 ("-----BEGIN RSA PRIVATE KEY-----\r"...)
    [+] file:/home/dev/.ssh/id_dsa PEM@0 ("-----BEGIN DSA PRIVATE KEY-----\n"...)
    [+] file:/home/dev/.ssh/id_rsa PEM@0 ("-----BEGIN RSA PRIVATE KEY-----\n"...)

