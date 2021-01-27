#!/usr/bin/perl
use strict;
use warnings;
use IO::Handle;
use constant PRINT_PERMUTATION => 0;

#!perl -w
use strict;
use warnings;

my $newMissSpelling;
my @completedWords;
my @missSpelledWords;
my $fh;

eval "use Win32::GUI()";
if($@){
    print "missing the library Win32::GUI()\n";
    open($fh, '<', 'wordlist.txt') or die "Failed to open file for reading\n";
}
else 
{
    my $lastfile = 'Wordlist.txt';
     
    # single file with graphics file filters

    my ( @file, $file );
    my ( @parms );
    push @parms,
      -filter =>
        [ 'TXT - Normal text File', '*.txt',
          'All Files - *', '*'
        ],
      -directory => ".\\",
      -title => 'Select a file containing words for autocorrect';

    push @parms, -file => $lastfile  if $lastfile;
    @file = Win32::GUI::GetOpenFileName ( @parms );
    #print "$_\n" for @file;
    #////////////////////////////////////////////////////////////////////////////////////
    # The Perl programming language join() function is used to connect 
    # all the elements of a specific list or array into a single string 
    # using a specified joining expression. The list is concatenated 
    # into one string with the specified joining element contained between each item
    #/////////////////////////////////////////////////////////////////////////////////////
    #print join('',@file), "\n"; #ONLY NEED TO USE JOIN IF SELECTING MULTIPLE FILES 
    print "index of null:",  index( $file[ 0 ], "\0" ), "\n";
    print "index of space:", index( $file[ 0 ], " " ), "\n";
    #open($fh, '<', join('',@file)) or die "Failed to open file for reading\n"; #ONLY NEED TO USE JOIN IF SELECTING MULTIPLE FILES 
    open($fh, '<', @file) or die "Failed to open file for reading\n";
}


chomp(my @orgWordList = <$fh>);
#foreach (@orgWordList) {
#  print "$_\n";
#}
close $fh;
# open(my $bigWordlist, '<', "Wordlist 100000 frequency weighted (Google Books).txt") or die "Failed to open file for reading\n";
open(my $bigWordlist, '<', "english3_gwicks.txt") or die "Failed to open file for reading\n";
chomp(my @dictionary = <$bigWordlist>);
close $bigWordlist;

#open($fh, '<', "wordlist.txt") or die "Failed to open file for reading\n";
open(my $fh_out, '>', "generatedwords.ahk")    or die "Failed to open file for writing\n";

#while (my $word = <$fh>)
my $iterCount = 0;
foreach my $word (@orgWordList)
{  
    my $foundSpellingAsWord = 0;
    my $foundGeneratedWord = 0;
    my $foundCompletedWord = 0;
    $iterCount ++;
    chomp $word;
    #Before even beginning look through the entire wordlist for duplicates
    foreach my $completedWords (@completedWords)
    {
        if ($word eq $completedWords) {
            print "line#" . $iterCount . " skipping word: " . $word . "\n";
            $foundCompletedWord = 1;
            last;
        }
    }#otherwise just skip the word all together and move on
    if ($foundCompletedWord == 1) {
        next;
    }
    push(@completedWords, $word);
    
    print "line#" . $iterCount . "------Next Word: " . $word . "------\n";
    
    # /////////////////////////////////////////////////////////////
    my @string_as_array = split('',$word);
    # my @arr = (2);
    # print scalar @arr; # First way to print array size

    # print $#arr; # prints the max index of array

    # my $arrSize = @arr;
    # print $arrSize; # Third way to print array size
    my $maxindex    = scalar(@string_as_array);
    if ($maxindex >= 2)
    {
        ##///////////////////////////////////////////////////////////////////////////
        ##this commented out code was originally rotating the letters to form new words
        ##///////////////////////////////////////////////////////////////////////////
        # for(my $index=0; $index <= $maxindex-1;     $index++)
        # {   
            # $foundSpellingAsWord = 0;
            # push (@string_as_array, shift(@string_as_array));
            # # print @string_as_array[$index],"\n";
            # # print @string_as_array,"\n";
            # $newMissSpelling = join('',@string_as_array);
            # if (PRINT_PERMUTATION)
            # {
                # print $newMissSpelling,"\n";
            # }
            # foreach my $orgWord (@orgWordList)
            # {
                # if ($newMissSpelling eq $orgWord)
                # {
                    # # print "same word found!\n";
                    # $foundSpellingAsWord = 1;
                    # last;
                # }
            # }
            
            # if ($foundSpellingAsWord == 0)
            # {
                # # print $newMissSpelling, "\n";
                # foreach my $aRealWord (@dictionary)
                # {
                    # if ($newMissSpelling eq $aRealWord)
                    # {
                       # $foundGeneratedWord  = 1;
                        # print "found " . $newMissSpelling , "\n";
                        # last;
                    # }
                # }
                # if ($foundGeneratedWord == 0)
                # {
                    # print $fh_out "::" . $newMissSpelling . "::" . $word, "\n";
                # }
                # push(@missSpelledWords, $newMissSpelling);
            # }
        # }
        ##///////////////////////////////////////////////////////////////////////////
        
        
        ##///////////////////////////////////////////////////////////////////////////
        ## First delete 1 letter at time to fix simple errors in spelling
        ##///////////////////////////////////////////////////////////////////////////
        for (my $index=0; $index < scalar(@string_as_array); $index++)
        {
            $foundSpellingAsWord = 0;
            $foundGeneratedWord  = 0;
            
            my @splicedString = @string_as_array;
            splice(@splicedString, $index, 1);
            
            $newMissSpelling = join('',@splicedString);
            #first check if the new spelling is a word from the wordlist.txt (assuming the 2 files are different)
            if (scalar(@orgWordList) != scalar(@dictionary))
            {
                foreach my $orgWord (@orgWordList)
                {
                    if ($newMissSpelling eq $orgWord)
                    {
                        $foundSpellingAsWord = 1;
                        last;
                    }
                }
            }   
            #if it is not, then check to see if it's a word in the dictionary and/or a word we've already generated
            if ($foundSpellingAsWord == 0) {
                foreach my $aGeneratedWord (@missSpelledWords)
                {
                    if ($newMissSpelling eq $aGeneratedWord) {
                        $foundGeneratedWord++;
                        print "found " . $newMissSpelling , " in missSpelledWords\n";
                        last;
                    }
                }
                if ($foundGeneratedWord == 0) {
                    foreach my $aRealWord (@dictionary)
                    {
                        if ($newMissSpelling eq $aRealWord) {
                            $foundGeneratedWord = 1;
                            print "found " . $newMissSpelling , " in dictionary\n";
                            last;
                        }
                    }
                }
                if ($foundGeneratedWord == 0) {
                    print $fh_out "::" . $newMissSpelling . "::" . $word, "\n";
                    push(@missSpelledWords, $newMissSpelling);
                }
            }
        }    
        ##///////////////////////////////////////////////////////////////////////////
        ## Next go through each and every letter and swap it with the next position 
        ##///////////////////////////////////////////////////////////////////////////
        for (my $index=0; $index < scalar(@string_as_array)-1; $index++)
        {
            $foundSpellingAsWord = 0;
            $foundGeneratedWord  = 0;
            my @firstLetters = 0;
            
            if ($index > 0){
                @firstLetters = @string_as_array[0 .. $index-1];
            }
               
            my @remainderLetters = @string_as_array[$index .. scalar(@string_as_array)-1];
            
            if (PRINT_PERMUTATION) {
                print @firstLetters, "===" , @remainderLetters, "\n";
            }
            
            my $remainingMaxIndex = scalar(@remainderLetters);
            if ($remainingMaxIndex >= 1) {
                for(my $subIndex=0; $subIndex < $remainingMaxIndex-1; $subIndex++)
                {   
                    @remainderLetters[$subIndex, $subIndex+1] = @remainderLetters[$subIndex+1, $subIndex];
                
                    if (PRINT_PERMUTATION) {
                        if ($index == 0){
                            print @remainderLetters,"\n";
                        }
                        else{
                            print @firstLetters;
                            print @remainderLetters,"\n";
                        }
                    }
                    
                    if ($index == 0) {
                        $newMissSpelling = join('',@remainderLetters);
                    }
                    else
                    {
                        $newMissSpelling = join('',@firstLetters) . join('',@remainderLetters);
                    }
                    
                    if (scalar(@orgWordList) != scalar(@dictionary))
                    {
                        foreach my $orgWord (@orgWordList)
                        {
                            if ($newMissSpelling eq $orgWord) {
                                $foundSpellingAsWord = 1;
                                last;
                            }
                        }
                    }
                    if ($foundSpellingAsWord == 0) {
                        foreach my $aGeneratedWord (@missSpelledWords)
                        {
                            if ($newMissSpelling eq $aGeneratedWord) {
                                $foundGeneratedWord++;
                                print "found " . $newMissSpelling , " in missSpelledWords\n";
                                last;
                            }
                        }
                        if ($foundGeneratedWord == 0) {
                            foreach my $aRealWord (@dictionary)
                            {
                                if ($newMissSpelling eq $aRealWord) {
                                    $foundGeneratedWord = 1;
                                    print "found " . $newMissSpelling , " in dictionary\n";
                                    last;
                                }
                            }
                        }
                        if ($foundGeneratedWord == 0) {
                            print $fh_out "::" . $newMissSpelling . "::" . $word, "\n";
                            push(@missSpelledWords, $newMissSpelling);
                        }
                    }
                }
                
                ##///////////////////////////////////////////////////////////////////////////
                ## Lastly, rotate each subset of letters 
                ##///////////////////////////////////////////////////////////////////////////
                # $foundSpellingAsWord = 0;
                # $foundGeneratedWord  = 0;
                # @firstLetters = @string_as_array[0 .. $index];
                # @remainderLetters = @string_as_array[$index+1 .. scalar(@string_as_array)-1];
                # $remainingMaxIndex = scalar(@remainderLetters);
                # for(my $subIndex=0; $subIndex < $remainingMaxIndex-1; $subIndex++)
                # {   
                    # push (@remainderLetters, shift(@remainderLetters));
                    # # unshift ( @remainderLetters, pop @remainderLetters );
                   
                    # if (PRINT_PERMUTATION)
                    # {
                        # print @firstLetters;
                        # print @remainderLetters,"\n";
                    # }
                    # # print @string_as_array[$index],"\n";
                    # $newMissSpelling = join('',@firstLetters) . join('',@remainderLetters);
                    # # print $newMissSpelling,"\n";
                    
                    # foreach my $orgWord (@orgWordList)
                    # {
                        # if ($newMissSpelling eq $orgWord)
                        # {
                            # # print "same word found!\n";
                            # $foundSpellingAsWord = 1;
                            # last;
                        # }
                    # }
                    # if ($foundSpellingAsWord == 0)
                    # {
                        # foreach my $aRealWord (@dictionary)
                        # {
                            # if ($newMissSpelling eq $aRealWord)
                            # {
                                # $foundGeneratedWord = 1;
                                # print "found " . $newMissSpelling , "\n";
                                # last;
                            # }
                        # }
                        # foreach my $aGeneratedWord (@missSpelledWords)
                        # {
                            # if ($newMissSpelling eq $aGeneratedWord)
                            # {
                                # $foundGeneratedWord++;
                            # }
                        # }
                        # if ($foundGeneratedWord == 0)
                        # {
                            # print $fh_out "::" . $newMissSpelling . "::" . $word, "\n";
                        # }
                        # push(@missSpelledWords, $newMissSpelling);
                    # }
                # }
            }
        }
    }
}
print "------COMPLETED GENERATION!!------\n";
close $fh;
close $fh_out; 