- When listing /api/packages code loops over array of indexes and 
reads from the begining of first package until the begining of the next,
on arrays with even length, that works, on arrays with odd length,
last package is not read (see status and verify 'libio-string-perl'
is not available on /api/packages list. Suggestion: revisit reading
of the whole index

- Find "the names of the packages that depend on the current package" (i.e.:
the packages depending on /api/packages/:name-package) is not implemented.
The strategy of indexing contents in memory is suboptimal (to say the least)
for this approach. Suggestion: graphs, maybe?
