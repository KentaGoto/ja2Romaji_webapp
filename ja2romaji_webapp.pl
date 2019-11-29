use Mojolicious::Lite;
use File::Copy;
use open IO => qw/:encoding(UTF-8)/;
binmode STDOUT, ':encoding(UTF-8)';

my $app = app;
my $url = 'http://localhost:3006'; # URL

get '/' => sub {
	my $self = shift;
	$self->render('index', top_page => $url);
};

post '/' => sub {
	my $self = shift;

	# Get parameter
	my $ja = $self->param('ja');
	
	# Error display when input is empty.
	if (! length $ja){
	  $self->render('index', error => 'Empty');
	  return;
	}

	unlink './tmp/ja.txt';
	
	# Create if there is no tmp folder.
	if ( -d './tmp' ){
	
	} else {
		mkdir 'tmp', 0700 or die "$!";
	}
	
	open( my $ja_out, ">:utf8", "tmp/ja.txt" ) or die "$!:ja.txt";
	my @ja_array = split(/\n/, $ja);
	foreach my $line (@ja_array){
		chomp($line);
		print {$ja_out} $line;
	}

	close($ja_out);
	
	# Generate Romaji
	my $command = 'ja2romaji.py ./tmp/ja.txt';
	my $command_result = `$command`;
	
	open ( my $in, "<:utf8", "Romaji.txt" ) or die "$!:Romaji.txt";
	my @romaji = <$in>;
	close $in;

	my @result;
	foreach ( @romaji ){
		chomp($_);
		push @result, $_;
	}
	
	# Display the results.
	$self->render(template => 'result',
					result => \@result
			     );
};

app->start;

__DATA__
@@ layouts/common.html.ep
<!doctype html>
<html lang="en">
  <head>
  	<meta charset="utf-8" />
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
	<style type="text/css">
		body {
		    font-family:-apple-system, BlinkMacSystemFont, "Helvetica Neue", "Segoe UI","Noto Sans Japanese","ヒラギノ角ゴ ProN W3", Meiryo, sans-serif;
				width:600px;
		}
		
		input.upload_button {
		    font-size: 1.0em;
		    font-weight: bold;
		    padding: 8px 20px;
		    background-color: #E38692;
		    color: #fff;
		    border-style: none;
		}
		
		input.upload_button:hover {
		    background-color: #CA3C6E;
		    color: #fff;
		}

		input.clear_button {
		    font-size: 1.0em;
		    font-weight: bold;
		    padding: 8px 20px;
		    background-color: #6EB7DB;
		    color: #fff;
		    border-style: none;
		}
		
		input.clear_button:hover {
		    background-color: #208DC3;
		    color: #fff;
		}
	</style>
	<link type="text/css" rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/cupertino/jquery-ui.min.css" />
	<script type="text/javascript" src="http://code.jquery.com/jquery-1.10.2.min.js"></script>
	<script type="text/javascript" src="http://code.jquery.com/ui/1.10.3/jquery-ui.min.js"></script>
	
	<title><%= stash('title') %></title>
  </head>
  <body>
    %= content;
  </body>
</html>

@@ index.html.ep
% layout 'common', title => 'ja2Romaji';
%= javascript begin
  // Progressbar
  $(document).on('click', '#submit', function() {
    $('#progress').progressbar({
        max: 10,
        value: false
		}).height(20);
		// Hide button
		$('#submit').hide();
		$('#clear').hide();
	});
% end
% my $top_page = stash('top_page');
% my $error = stash('error');
% if ($error) {
  <div style="color:red">
    <%= $error %>
  </div>
% }
<h1>ja2Romaji</h1>
<form action="<%= url_for %>" method="post">
  <%= text_area 'ja', style => "width:600px; height:300px", placeholder => "Japanese" %><br>
  </br>
  <input class="upload_button" type="submit" id="submit" value="Submit">
	<div id="progress"></div>
</form>
</br>
<input class="clear_button" type="button" id="clear" value="Clear" onClick="location.href='<%= $top_page %>'">
</br>
</br>
<!-- <a href="/static/README.html">README</a> -->

@@ result.html.ep
% layout 'common', title => 'Results';
% for my $line (@$result){ 
<%= $line %></br>
% }
