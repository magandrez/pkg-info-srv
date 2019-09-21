- Find "the names of the packages that depend on the current package" (i.e.:
the packages depending on /api/packages/:name-package) is not implemented.
The strategy of indexing contents in memory is suboptimal (to say the least)
for this approach. Suggestion: graphs, maybe?
