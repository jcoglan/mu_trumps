#!/usr/bin/env python
# encoding: utf-8
"""
populate_release_data.py

Created by Benjamin Fields on 2011-01-24.
Copyright (c) 2011 Goldsmith University of London. All rights reserved.
"""

import sys
import os
import logging

from musicbrainz2.webservice import Query, ArtistFilter, WebServiceError
import musicbrainz2.webservice as ws
import musicbrainz2.model as m
from time import sleep, strftime

import sqlite3

SLEEP_TIME = 1.4
VERBOSE = False

def main(argv=None):
	if argv==None:
		argv=sys.argv
	
	q = Query()
	
	conn = sqlite3.connect('db/pop_trumps.sqlite3')
	c = conn.cursor()
	insert_cursor = conn.cursor()
	c.execute('select * from artists')
	
	for artist_id, created, modified, artist_name, artist_url in c:
		try:
			# Search for all artists matching the given name. Limit the results
			# to the best match. 
			f = ArtistFilter(name=artist_name, limit=5)
			artistResults = q.getArtists(f)
		except WebServiceError, e:
			print 'Error:', e
			continue
		try:
			mbz_id = artistResults[0].artist.id
		except IndexError:
			print "Could not find a musicbrainz id for the artist", artist_name, "moving on..."
			continue
		if VERBOSE:
			print "For artist", artist_name, "found id", artist_id
		try:
			# The result should include all official albums.
			#
			inc = ws.ArtistIncludes(
				releases=(m.Release.TYPE_OFFICIAL, m.Release.TYPE_ALBUM),
				tags=True, releaseGroups=True)
			artist = q.getArtistById(mbz_id, inc)
		except ws.WebServiceError, e:
			print 'Error:', e
			continue
		album_count = len(artist.getReleases())
		if VERBOSE:
			print "\thas released", album_count,"albums."
		try:
			# The result should include all official albums.
			#
			inc = ws.ArtistIncludes(
				releases=(m.Release.TYPE_OFFICIAL, m.Release.TYPE_SINGLE),
				tags=True, releaseGroups=True)
			artist = q.getArtistById(mbz_id, inc)
		except ws.WebServiceError, e:
			print 'Error:', e
			continue
		single_count = len(artist.getReleases())
		if VERBOSE:
			print "\thas released", single_count,"singles."
		insert_cursor.execute("""select * from statistics where artist_id = %i and name = 'albums'"""%artist_id)
		if len(list(insert_cursor)) == 0:
			insert_cursor.execute(\
				"""insert into statistics ("created_at","updated_at", "artist_id", "name", "value") \
				values ('%s','%s',%i,'%s',%i)"""%(strftime("%Y-%m-%d %H:%M:%S"),
										strftime("%Y-%m-%d %H:%M:%S"),
										artist_id, 
										'albums', 
										album_count))
		else:
			insert_cursor.execute(\
			"""update statistics set "updated_at" = '%s', "value" = %i\
			 where artist_id = %i and name = 'album'"""%(strftime("%Y-%m-%d %H:%M:%S"), album_count, artist_id))
		insert_cursor.execute("""select * from statistics where artist_id = %i and name = 'singles'"""%artist_id)
		if len(list(insert_cursor)) == 0:
			insert_cursor.execute(\
				"""insert into statistics ("created_at","updated_at", "artist_id", "name", "value") \
				values ('%s','%s',%i,'%s',%i)"""%(strftime("%Y-%m-%d %H:%M:%S"),
										strftime("%Y-%m-%d %H:%M:%S"),
										artist_id, 
										'singles', 
										single_count))
		else:
			insert_cursor.execute(\
			"""update statistics set "updated_at" = '%s', "value" = '%i'\
			 where artist_id = %i and name = 'album'"""%(strftime("%Y-%m-%d %H:%M:%S"), single_count, artist_id))
		conn.commit()
		if VERBOSE:
			print "values updated/inserted."
		sleep(SLEEP_TIME)
	conn.close()

if __name__ == '__main__':
	main()