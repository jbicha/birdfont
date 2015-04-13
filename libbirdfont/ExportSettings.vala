/*
    Copyright (C) 2015 Johan Mattsson

    This library is free software; you can redistribute it and/or modify 
    it under the terms of the GNU Lesser General Public License as 
    published by the Free Software Foundation; either version 3 of the 
    License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful, but 
    WITHOUT ANY WARRANTY; without even the implied warranty of 
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
    Lesser General Public License for more details.
*/

using Cairo;
using Math;

namespace BirdFont {

public class ExportSettings : TableLayout {
	TextArea file_name;
	CheckBox ttf;
	CheckBox eot;
	CheckBox svg;
	Button export_action;
	Button name_tab;
	
	public ExportSettings () {
		Headline headline;
		Font font;
		double margin = 12 * MainWindow.units;
		double label_size = 20 * MainWindow.units;
		double label_margin = 4 * MainWindow.units;
		string fn;
		
		font = BirdFont.get_current_font ();		
		font.settings.set_setting ("has_export_settings", "true");
		
		headline = new Headline (t_("Export Settings"));
		headline.margin_bottom = 20 * MainWindow.units;
		widgets.add (headline);
		
		widgets.add (new Text (t_("File Name"), label_size, label_margin));
		
		file_name = new LineTextArea (label_size);
		file_name.margin_bottom = margin;
		
		fn = get_file_name (font);
		file_name.set_text (fn);
		file_name.text_changed.connect ((t) => {
			Font f = BirdFont.get_current_font ();
			f.settings.set_setting ("file_name", t);
		});
		
		widgets.add (file_name);
		focus_ring.add (file_name);
		
		widgets.add (new Text (t_("Formats"), label_size, label_margin));

		ttf = new CheckBox ("TTF", label_size);
		ttf.updated.connect ((c) => {
			Font f = BirdFont.get_current_font ();
			string v = c ? "true" : "false";
			f.settings.set_setting ("export_ttf", v);
		});
		ttf.checked = export_ttf_setting (font);
		widgets.add (ttf);
		focus_ring.add (ttf);

		eot = new CheckBox ("EOT", label_size);
		eot.updated.connect ((c) => {
			Font f = BirdFont.get_current_font ();
			string v = c ? "true" : "false";
			f.settings.set_setting ("export_eot", v);
		});
		eot.checked = export_eot_setting (font);
		widgets.add (eot);
		focus_ring.add (eot);
		
		svg = new CheckBox ("SVG", label_size);
		svg.updated.connect ((c) => {
			Font f = BirdFont.get_current_font ();
			string v = c ? "true" : "false";
			f.settings.set_setting ("export_eot", v);
		});
		svg.checked = export_svg_setting (font);
		svg.margin_bottom = margin;
		widgets.add (svg);
		focus_ring.add (svg);

		name_tab = new Button (t_("Name and Description"), margin);
		name_tab.action.connect ((c) => {
			MenuTab.show_description ();
		});
		widgets.add (name_tab);
				
		export_action = new Button (t_("Export"), margin);
		export_action.action.connect ((c) => {
			MenuTab.export_fonts_in_background ();
		});
		widgets.add (export_action);
			
		set_focus (file_name);
	}
	
	public static string get_file_name (Font font) {
		string n = font.settings.get_setting ("file_name");
		
		if (n == "") {
			n = font.full_name;
		}
		
		return n;
	}

	public static bool export_ttf_setting (Font f) {
		return f.settings.get_setting ("export_ttf") != "false";
	}

	public static bool export_eot_setting (Font f) {
		return f.settings.get_setting ("export_eot") != "false";
	}
	
	public static bool export_svg_setting (Font f) {
		return f.settings.get_setting ("export_svg") != "false";
	}
		
	public static bool has_export_settings (Font f) {
		return f.settings.get_setting ("has_export_settings") == "true";
	}
		
	public override string get_label () {
		return t_("Export Settings");
	}

	public override string get_name () {
		return "Export Settings";
	}
}

}