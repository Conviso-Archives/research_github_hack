#!/usr/bin/perl -io
=pod
This is github crawler,
to help you on github hacks.

Before to run, 
you need install some Perl modules:

 $ cpan -i LWP
 $ cpan -i URI
 $ cpan -i Term::ANSIColor
 $ cpan -i LWP::Protocol::https 

 $ perl github_crawler.pl

Example to use:
 $ perl github_hack.pl password login out.txt 2
                        
password = string to search on github site

login = string to search on github source codes,
        you can use pcre regex here.

out.txt = objective of this file is populate the result URLs, 
          that have on "regex" search pattern...

2 = search on two pages

------

Greets:
@usscastro, @spookerlabs, @marcos_alvares, @conviso ...


=cut
# load modules
use LWP;
use URI;
use Term::ANSIColor;
print color 'green';

sub clear() {
 my $cmd=0; my $sys="$^O"; 
 if($sys eq "linux") { $cmd="clear"; } else {  $cmd="cls"; }
 print `$cmd`;
}

sub banner() {
 print q{

       _ _   _           _       _                _    
  __ _(_) |_| |__  _   _| |__   | |__   __ _  ___| | __
 / _` | | __| '_ \| | | | '_ \  | '_ \ / _` |/ __| |/ /
| (_| | | |_| | | | |_| | |_) | | | | | (_| | (__|   < 
 \__, |_|\__|_| |_|\__,_|_.__/  |_| |_|\__,_|\___|_|\_\
 |___/                                                                  
    ---------------------------------------------
               Coded By Cooler_
    ---------------------------------------------
                 Version 0.02 Beta

 contact: acosta[at]conviso[dot]com[dot]br
          c00f3r[at]gmail[dot]com
}
}

my @config = (
 'User-Agent'=>'Mozilla/4.76 [en] (Win98 ninja jiraia limited edition; U)',
 'Accept-Charset'=>'iso-8859-1',
 'Accept-Language'=>'en-US',
  'max_redirect' => 3,
 'Accept-Encoding' => 'gzip',
);

$git_search = $ARGV[0]; 
$grep = $ARGV[1];
$txt = $ARGV[2];
$pages = $ARGV[3];

print "Searching to:";
print color 'yellow'; 
print " $git_search\n";
print color 'green';
print "save file:";
print color 'yellow'; 
print " $txt\n";
print color 'green';
print "Pattern to search: "; 
print color 'yellow';
print " $grep\n";
print color 'reset';

if((!$git_search)&&(!$txt)&&(!$grep)) 
{
 print color 'green'; 
 banner(); 
 print "Please follow the example ./programm str_2_search_on_git find_on_source_codes file_log.txt number_of_pages_2_search\n"; 
 print color 'reset'; 
 exit; 
}

if(($git_search)&&($txt)) 
{
 banner();

# items to search per page, default is 20
 if(!$pages)
 {
  $pages=20;
 } 

 for($num=0; $num<=$pages; $num++) 
 {
# request
#  "https://github.com/search?l=&p=$num&q=$busca&ref=advsearch&type=Code";
  $url=URI->new('https://github.com/search?l=');
  $url->query_form('p'=>$num,'q'=>$git_search,'ref'=>'advsearch','type'=>'Code');
  $request=LWP::UserAgent->new;
  my $response=$request->get($url,@config);
#  $res=$response->content;
  $res=$response->decoded_content(charset => 'utf8');
  
  @html = split "\n", $res;
  $parse=0;
  @urls;

# parser on response
  foreach(@html) 
  {
# wait if block... 
    if($_ =~ m/Whoa there\!/) 
    {
     $parse=0;
     print "wait delay";
     sleep 2;
     break;
    }

    if($parse eq 1) 
    {
     if($_ =~ m/\/table/) 
     {
      $parse=0;
     }
     
# extract URL      
     if($_ =~ /<a href="(.*?)" title/ )
     {
      $tmp=$1;
      $link_raw="https://raw.github.com$tmp";
      $link_raw =~ s/blob\///;
      $link="https://github.com$tmp";
      $request=LWP::UserAgent->new;
      my $response=$request->get($link_raw,@config);
      $res=$response->decoded_content(charset => 'utf8');  
 #     $res=$response->content;
      @html_source = split "\n", $res;
      $source_parse=0;
 
      print "$link \n";
# grep on source code    
      foreach(@html_source)
      {
        if($_ =~ /$grep/)
        {
         print color 'green';
         print "[ found ] : ";
         print color 'reset';
         print " search string \"$grep\" on $link \n";
# write logs
         open my $fh, '>>', "$txt" or die "Cannot open $txt: $!";
          print $fh "$link\n"; 
         close $fh;
         break;
        }      

      }

      push(@urls,$link);
     }

    } 

    if($_ =~ m/code-list-item/)
    {
     $parse=1;
    }
    
  }
  sleep 2;
 }   

 clear(); banner();
 print "---------------\nTotal off links ".scalar @urls."\n fault strings on grep, save in $txt\n"; 
 sleep 1; 
 print color 'reset'; 
 exit;
}
