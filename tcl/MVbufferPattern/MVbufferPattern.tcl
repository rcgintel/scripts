

namespace eval kdheeraj {
puts "using rcg MV scripts"
}



proc kdheeraj::MVBufferPattern {args} {
## set default values 
set opt(-Verbose) 0

parse_proc_arguments -args ${args} opt
set Row -$opt(-Row)
set Column -$opt(-Column)
set Verbose $opt(-Verbose)
set IsoName $opt(-IsoName)
set Coordinate $opt(-Coordinate)
set GroupDirection $opt(-GroupDirection)
#### get the isolation strategy name and get the isolation cells associated to those strategy

# start placing the iolation cells from location given in the coordinates
# verify the isolation cells are placed legalized or not check for overlap

}

define_proc_attributes rcg::MVBoundCreate \
    -info "this script is to place the isolation cells in a pattern for handling MV issues" \
    -hide_body \
    -define_args {
        {-IsoName "give the isolation strategy name " "" string required}
        {-Coordinate "give the start coordinate for placing isolation cells " "" string required}
        {-GroupDirection "give the direction left (0) /right (1) for grouping the cells" "" boolean required}
        {-Row "give the number of rows for the iso to be grouped into " "" string required}
        {-Column "give the number of column for the iso to be grouped into " "" string required}
        {-Verbose "verbose " "" boolean optional 0}
}







