foreach( glob("t/*+*.t") ){
  print "Running $_...\n";
  system($^X, '-Mblib', $_);
}
