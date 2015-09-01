#!/usr/bin/python
# Print the closest apache mirror for the given project

import urllib2, json, argparse, os

parser = argparse.ArgumentParser(description='gets the closest Apache Mirror for a project')
parser.add_argument('project', help='project to get the mirror for')
parser.add_argument('-v', '--version', help='project version')
parser.add_argument('-f', '--file', help='filename of binary')

args = parser.parse_args()

closer_url = 'http://www.apache.org/dyn/closer.cgi/{0}/?as_json=1'.format(args.project)

response = json.loads(urllib2.urlopen(closer_url).read())

path = response['path_info']

#added this 01/09/15
path = format(args.project)


if args.version:
    path = os.path.join(path, args.version)

if args.file:
    path = os.path.join(path, args.file)

print response['preferred'] + path


