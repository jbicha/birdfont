/*
    Copyright (C) 2012 Johan Mattsson

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

using Cairo;

namespace Supplement {

public class SpinButton : Tool {

	public signal void new_value_action (SpinButton selected);
	
	public int8 deka = 2;
	public int8 deci = 0;
	public int8 centi = 0;
	public int8 milli = 0;
	
	bool value_from_motion = false;
	double begin_y = 0;
	int begin_value = 0;
	
	int max = 9999;
	int min = 0;
	
	public SpinButton (string? name = null, string tip = "", unichar key = '\0', uint modifier_flag = 0) {
		base (null , tip, key, modifier_flag);
		
		if (name != null) {
			base.name = (!) name;
		}
		
		set_icon ("spin_button");
		
		panel_press_action.connect ((selected, button, tx, ty) => {
			double py = Math.fabs (y - ty);
			int n;

			if (is_selected ()) {
				n = (button == 3) ? 10 : 1;
					
				for (int i = 0; i < n; i++) {
					if (py < 28) increase ();
					if (py > 35) decrease ();
				}
			}
			
			value_from_motion = true;
			begin_y = ty;
			
			begin_value = get_int_value ();
		});

		panel_move_action.connect ((selected, button, tx, ty) => {
			double d;
			int new_value;
			
			if (value_from_motion) {
				d = (begin_y - ty) / 200;
				d = (d < 0) ? -Math.pow (d, 2) : Math.pow (d, 2);
				d *= 1000;

				new_value = (int)(begin_value + d);
				
				if (new_value < min) {
					set_int_value (@"$min");
				} else if (new_value > max) {
					set_int_value (@"$max");
				} else {
					set_int_value (@"$new_value");
				}
			}
		});

		panel_release_action.connect ((selected, button, tx, ty) => {
			value_from_motion = false;
		});
	}
	
	public void set_max (double max) {
		this.max = (int) Math.rint (max * 1000);
	}

	public void set_min (double min) {
		this.min = (int) Math.rint (min * 1000);
	}
	
	public void increase () {	
		int v;
		
		v = get_int_value ();
		v++;
		
		if (v > max) {
			set_int_value (@"$max");
		} else {
			set_int_value (@"$v");
		}

		new_value_action (this);
	}

	public void decrease () {
		int v;
		
		v = get_int_value ();
		v--;

		if (v <= min) {
			set_int_value (@"$min");
		} else {
			set_int_value (@"$v");
		}
				
		new_value_action (this);
	}

	public void set_int_value (string new_value) {
		string v = new_value;
		
		while (!(v.char_count () >= 4)) {
			v = "0" + v;
		}
		
		deka = parse (v.substring (v.index_of_nth_char (0), 1));
		deci = parse (v.substring (v.index_of_nth_char (1), 1));
		centi = parse (v.substring (v.index_of_nth_char (2), 1));
		milli = parse (v.substring (v.index_of_nth_char (3), 1));
		
		new_value_action (this);
	}

	int8 parse (string s) {
		int v = int.parse (s);
		if (v < 0) {
			warning ("Failed to parse integer.");
			return 0;
		}
		return (int8) v;
	}

	public void set_value (string new_value, bool check_boundries = true, bool emit_signal = true) {
		string v = new_value;

		while (!(v.char_count () >= 5)) {
			if (v.index_of (".") == -1) {
				v += ".";
			} else {
				v += "0";
			}
			
			return;
		}

		deka = (int8) int.parse (v.substring (v.index_of_nth_char (0), 1));
		deci = (int8) int.parse (v.substring (v.index_of_nth_char (2), 1));
		centi = (int8) int.parse (v.substring (v.index_of_nth_char (3), 1));
		milli = (int8) int.parse (v.substring (v.index_of_nth_char (4), 1));
		
		if (emit_signal) {
			new_value_action (this);
		}
		
		if (check_boundries && get_value () > max) {
			set_value_round (max, false);
		}

		if (check_boundries && get_value () < min) {
			set_value_round (min, false);
		}
	}

	public void set_value_round (double v, bool check_boundries = true, bool emit_signal = true) {
		v *= 1000;
		v = Math.rint (v);
		set_value (@"$v", check_boundries, emit_signal);
	}
	
	public double get_value () {
		return deka + (deci / 10.0) + (centi / 100.0) + (milli / 1000.0);
	}
	
	private int get_int_value () {
		return deka * 1000 + deci * 100 + centi * 10 + milli;
	}

	public string get_display_value () {
		return @"$deka.$deci$centi$milli";
	}

	public override void draw (Context cr) {
		double xt = x + 3 + w;
		double yt = y + h + 17;

		double text_x = -4.5;
		double text_y = 11;

		base.draw (cr);
	
		cr.save ();
	
		cr.set_source_rgba (99/255.0, 99/255.0, 99/255.0, 1);
		
		cr.set_font_size (10);
		cr.select_font_face ("Cantarell", FontSlant.NORMAL, FontWeight.NORMAL);

		cr.move_to (xt + text_x, yt + text_y);
		
		cr.show_text (get_display_value ());
		
		cr.restore ();
	}
}

}
