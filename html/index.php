<?php

$lines = file("https://object.pouta.csc.fi/OPUS-MT-models/index.txt");
foreach ($lines as $line){
  $line = rtrim($line);
  if (substr($line, -4) === '.zip'){
    $parts = explode('/',$line);
    $langs = explode('-',$parts[0]);
    if (strpos($langs[0],'+') || strpos($langs[1],'+')){
      $multilingual["$langs[0]-$langs[1]"]=1;
      $src = explode('+',$langs[0]);
      $trg = explode('+',$langs[1]);
      foreach ($src as $s){
	foreach ($trg as $t){
	  if (!array_key_exists("$s$t",$models)){
	    $models["$s$t"] = "$langs[0]-$langs[1]";
	    $nrlangpairs++;
	  }
	  $nrmultipairs++;
	  $srclangs[$s]=1;
	  $trglangs[$t]=1;
	  $languages[$s]=1;
	  $languages[$t]=1;
	}
      }
    }
    else{
      if (!array_key_exists("$langs[0]$langs[1]",$models)){
	$nrlangpairs++;
      }
      $bilingual["$langs[0]-$langs[1]"]=1;
      $models["$langs[0]$langs[1]"] = "$langs[0]-$langs[1]";
      // $models["$langs[0]$langs[1]"] = $line;
      $srclangs[$langs[0]]=1;
      $trglangs[$langs[1]]=1;
      $languages[$langs[0]]=1;
      $languages[$langs[1]]=1;
      $nrmodels++;
    }
  }
}

// ksort($languages);
ksort($srclangs);
ksort($trglangs);
ksort($multilingual);

echo("<html><head></head><body>");
echo("<h1>Pre-trained Opus-MT Models</h1><ul>");
// echo("<li>Number of bilingual models: $nrmodels</li>");

echo("<li>Number of bilingual models: ");
echo(count($bilingual));
echo("</li>");

echo("<li>Number of multilingual models: ");
echo(count($multilingual));
echo("</li>");

echo("<li>Number of supported source languages: ");
echo(count($srclangs));
echo("</li>");
echo("<li>Number of supported target languages: ");
echo(count($trglangs));
echo("</li>");

echo("<li>Number of supported language pairs: $nrlangpairs</li>");
echo("<li>Language pairs supported by multilingual models: $nrmultipairs</li>");
echo('</ul>');


echo("<h2>Multilingual models</h2><ul>");
foreach ($multilingual as $model => $c){
  echo("<li><a href=\"https://github.com/Helsinki-NLP/OPUS-MT-train/tree/master/models/$model\">$model</a></li>");
}
echo('</ul>');


echo("<h2>Language pairs</h2><ul>");

echo('<table><tr><th></th>');
foreach ($trglangs as $language => $count){
  echo '<th>';
  echo $language;
  echo '</th>';
}
echo('</tr>');
foreach ($srclangs as $src => $count){
  echo "<tr><td>$src</td>";
  foreach ($trglangs as $trg => $count){
    if (array_key_exists("$src$trg",$models)){
      echo("<td><a href=\"https://github.com/Helsinki-NLP/OPUS-MT-train/tree/master/models/");
      echo($models["$src$trg"]);
      if ($models["$src$trg"] != "$src-$trg"){
	echo("\">multi</a></td>\n");
      }
      else{
	echo("\">$src$trg</a></td>\n");
      }
    }
    else{
      echo("<td>-</td>");
    }
  }
  echo('</tr>');
}

echo('</table>');
echo('</body></html>');

?>
