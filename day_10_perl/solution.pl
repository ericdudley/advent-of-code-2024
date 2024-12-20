use strict;
use warnings;

sub parse_input {
    my $filename = shift;
    my @grid;
    open my $fh, '<', $filename or die $!;
    while (<$fh>) {
        chomp;
        my @row = map { $_ + 0 } split('', $_);
        push @grid, \@row;
    }
    close $fh;
    return @grid;
}

sub is_valid {
    my ($r, $c, $rows, $cols) = @_;
    return $r >= 0 && $r < $rows && $c >= 0 && $c < $cols;
}

sub build_adjacency_list {
    my ($grid_ref) = @_;
    my @dirs = ([1,0],[-1,0],[0,1],[0,-1]);
    my %adj;

    my $num_rows = scalar @$grid_ref;
    my $num_cols = scalar @{$grid_ref->[0]};

    for my $r (0..$num_rows-1) {
        for my $c (0..$num_cols-1) {
            my @neighbors;
            for my $dir (@dirs) {
                my ($nr, $nc) = ($r + $dir->[0], $c + $dir->[1]);
                if (is_valid($nr, $nc, $num_rows, $num_cols)) {
                    push @neighbors, [$nr, $nc];
                }
            }
            $adj{"$r,$c"} = \@neighbors;
        }
    }
    return %adj;
}

# Counts the unique "9" nodes reachable from each "0"
sub solve_part1_rec {
    my ($r, $c, $adj_ref, $grid_ref, $visited_ref, $local_nines_ref) = @_;
    return if $visited_ref->{"$r,$c"};

    $visited_ref->{"$r,$c"} = 1;
    my $val = $grid_ref->[$r][$c];

    if ($val == 9) {
        $local_nines_ref->{"$r,$c"} = 1;
        return;
    }
    foreach my $neighbor (@{$adj_ref->{"$r,$c"}}) {
        my ($nr, $nc) = @$neighbor;
        if ($grid_ref->[$nr][$nc] == $val + 1) {
            solve_part1_rec($nr, $nc, $adj_ref, $grid_ref, $visited_ref, $local_nines_ref);
        }
    }
}

sub solve_part1 {
    my ($grid_ref, $adj_ref) = @_;
    my $num_rows = scalar @$grid_ref;
    my $num_cols = scalar @{$grid_ref->[0]};
    my $total_count = 0;

    for my $r (0..$num_rows-1) {
        for my $c (0..$num_cols-1) {
            if ($grid_ref->[$r][$c] == 0) {
                my %visited;
                my %local_nines;
                solve_part1_rec($r, $c, $adj_ref, $grid_ref, \%visited, \%local_nines);
                $total_count += scalar keys %local_nines; # add the unique 9s found
            }
        }
    }
    return $total_count;
}

# Counts the total number of distinct paths from each "0" to any "9"
sub solve_part2_rec {
    my ($r, $c, $adj_ref, $grid_ref, $memo_ref) = @_;
    return $memo_ref->{"$r,$c"} if exists $memo_ref->{"$r,$c"};

    my $val = $grid_ref->[$r][$c];
    if ($val == 9) {
        $memo_ref->{"$r,$c"} = 1;
        return 1;
    }

    my $count_paths = 0;
    foreach my $neighbor (@{$adj_ref->{"$r,$c"}}) {
        my ($nr, $nc) = @$neighbor;
        if ($grid_ref->[$nr][$nc] == $val + 1) {
            $count_paths += solve_part2_rec($nr, $nc, $adj_ref, $grid_ref, $memo_ref);
        }
    }

    $memo_ref->{"$r,$c"} = $count_paths;
    return $count_paths;
}

sub solve_part2 {
    my ($grid_ref, $adj_ref) = @_;
    my $num_rows = scalar @$grid_ref;
    my $num_cols = scalar @{$grid_ref->[0]};
    my $total_score = 0;

    for my $r (0..$num_rows-1) {
        for my $c (0..$num_cols-1) {
            if ($grid_ref->[$r][$c] == 0) {
                my %memo;
                my $paths_from_zero = solve_part2_rec($r, $c, $adj_ref, $grid_ref, \%memo);
                $total_score += $paths_from_zero;
            }
        }
    }
    return $total_score;
}

my ($input_filename) = @ARGV;
my @grid = parse_input($input_filename);
my %adj  = build_adjacency_list(\@grid);

my $answer_part1 = solve_part1(\@grid, \%adj);
print "Part1 Sum of reachable 9s from each 0: $answer_part1\n";

my $answer_part2 = solve_part2(\@grid, \%adj);
print "Part2 Sum of distinct paths to 9s from each 0: $answer_part2\n";
