import 'dart:io';
import 'package:flutter/services.dart';


class PageBuilder {
	static final PageBuilder _singleton = new PageBuilder._internal();

	factory PageBuilder() {
		return _singleton;
	}


	Future<String> buildHTMLFile(String gameHTML) async {
		var boiler = "";
		try {
	      // Read the file
	      boiler = await rootBundle.loadString("assets/htmlGameBoiler.txt");
	    } catch (e) {
	      // If we encounter an error, return 0
	      	return "0"; //error
	    }
	    return boiler;
	    /*
		int beginBody = boiler.lastIndexOf("<body>") + 6;
		int endBody = boiler.indexOf('<script src="https://www.carolinaignites.org/assets/js/gameframe.js"></script>') - 1;
		String begin = boiler.substring(0, beginBody + 1);
		String end = boiler.substring(endBody);
		return begin + gameHTML + end;
		*/
	}

	Future<String> getJSBoiler() async {
		var boiler = "";
		try {
	      // Read the file
	      boiler = await rootBundle.loadString("assets/jsGameBoiler.txt");
	    } catch (e) {
	      // If we encounter an error, return 0
	      	return "0"; //error
	    }
	    return boiler;
	}



	Future<String> buildJSFile(String gameJS) async {
		var boiler = "";
		try {
	      // Read the file
	      boiler = await rootBundle.loadString("assets/jsGameBoiler.txt");
	    } catch (e) {
	      // If we encounter an error, return 0
	      	return "0"; //error
	    }
		int beginScript = boiler.lastIndexOf('<script type="text/javascript">') + 31;
		int endScript= boiler.indexOf("</script>", beginScript) - 1; //searches after the index of the script were looking for
		String begin = boiler.substring(0, beginScript);
		String end = boiler.substring(endScript);
		return begin + gameJS + end;
	}

	PageBuilder._internal();
}