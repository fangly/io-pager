for (sort glob "t/*interactive.t") {
  print "Running $_...\n";
  system($^X, '-Mblib', $_);
}
print "Done\n";
