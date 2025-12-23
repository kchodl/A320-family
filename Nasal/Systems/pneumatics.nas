# A3XX Pneumatic System
# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

# Local vars
var cabinalt = nil;
var targetalt = nil;
var ambient = nil;
var cabinpsi = nil;
var state1 = nil;
var state2 = nil;
var pressmode = nil;
var wowl = nil;
var wowr = nil;
var vs = nil;
var manvs = nil;
var pause = nil;
var auto = nil;
var speed = nil;
var ditch = nil;
var outflowpos = nil;
var targetvs = nil; 
var eng1_starter = nil;
var eng2_starter = nil;
var VS_MAX = 750;
var last_press_elapsed = nil;
var press_avail_latched = 0;
var press_avail_drop_s = 0;
var cabinalt_bootstrap_done = 0;
var cabinalt_bootstrap_t0 = nil;

# Main class
var PNEU = {
	Fail: {
		apu: props.globals.getNode("/systems/failures/pneumatics/apu-valve"),
		bleed1: props.globals.getNode("/systems/failures/pneumatics/bleed-1-valve"),
		bleed2: props.globals.getNode("/systems/failures/pneumatics/bleed-2-valve"),
		bmc1: props.globals.getNode("/systems/failures/pneumatics/bmc-1"),
		bmc2: props.globals.getNode("/systems/failures/pneumatics/bmc-2"),
		cabinFans: props.globals.getNode("/systems/failures/pneumatics/cabin-fans"),
		hotAir: props.globals.getNode("/systems/failures/pneumatics/hot-air-valve"),
		hp1Valve: props.globals.getNode("/systems/failures/pneumatics/hp-1-valve"),
		hp2Valve: props.globals.getNode("/systems/failures/pneumatics/hp-2-valve"),
		pack1: props.globals.getNode("/systems/failures/pneumatics/pack-1-valve"),
		pack2: props.globals.getNode("/systems/failures/pneumatics/pack-2-valve"),
		ramAir: props.globals.getNode("/systems/failures/pneumatics/ram-air-valve"),
		trimValveCockpit: props.globals.getNode("/systems/failures/pneumatics/trim-valve-cockpit"),
		trimValveAft: props.globals.getNode("/systems/failures/pneumatics/trim-valve-cabin-aft"),
		trimValveFwd: props.globals.getNode("/systems/failures/pneumatics/trim-valve-cabin-fwd"),
		xbleed: props.globals.getNode("/systems/failures/pneumatics/x-bleed-valve"),
	},
	Packs: {
		packFlow1: props.globals.getNode("/ECAM/Lower/pack-1-flow-output"),
		packFlow2: props.globals.getNode("/ECAM/Lower/pack-2-flow-output"),
		pack1OutTemp: props.globals.getNode("/systems/air-conditioning/packs/pack-1-output-temp"),
		pack2OutTemp: props.globals.getNode("/systems/air-conditioning/packs/pack-2-output-temp"),
		pack1OutletTemp: props.globals.getNode("/systems/air-conditioning/packs/pack-1-outlet-temp"),
		pack2OutletTemp: props.globals.getNode("/systems/air-conditioning/packs/pack-2-outlet-temp"),
		trimCockpit: props.globals.getNode("/ECAM/Lower/trim-cockpit-output"),
		trimAft: props.globals.getNode("/ECAM/Lower/trim-aft-output"),
		trimFwd: props.globals.getNode("/ECAM/Lower/trim-fwd-output"),
		cockpitDuctTemp: props.globals.getNode("/systems/air-conditioning/temperatures/cockpit-duct"),
		cabinAftDuctTemp: props.globals.getNode("/systems/air-conditioning/temperatures/cabin-aft-duct"),
		cabinFwdDuctTemp: props.globals.getNode("/systems/air-conditioning/temperatures/cabin-fwd-duct"),
		cockpitTemp: props.globals.getNode("/systems/air-conditioning/temperatures/cockpit-temp"),
		cabinAftTemp: props.globals.getNode("/systems/air-conditioning/temperatures/cabin-aft-temp"),
		cabinFwdTemp: props.globals.getNode("/systems/air-conditioning/temperatures/cabin-fwd-temp"),
	},
	Psi: {
		engine1: props.globals.getNode("/systems/pneumatics/psi/engine-1-psi"),
		engine2: props.globals.getNode("/systems/pneumatics/psi/engine-2-psi"),
	},
	Switch: {
		apu: props.globals.getNode("/controls/pneumatics/switches/apu"),
		bleed1: props.globals.getNode("/controls/pneumatics/switches/bleed-1"),
		bleed2: props.globals.getNode("/controls/pneumatics/switches/bleed-2"),
		blower: props.globals.getNode("/controls/pneumatics/switches/blower"),
		cabinFans: props.globals.getNode("/controls/pneumatics/switches/cabin-fans"),
		extract: props.globals.getNode("/controls/pneumatics/switches/extract"),
		groundAir: props.globals.getNode("/controls/pneumatics/switches/ground-air"),
		hotAir: props.globals.getNode("/controls/pneumatics/switches/hot-air"),
		pack1: props.globals.getNode("/controls/pneumatics/switches/pack-1"),
		pack2: props.globals.getNode("/controls/pneumatics/switches/pack-2"),
		packFlow: props.globals.getNode("/controls/pneumatics/switches/pack-flow"),
		ramAir: props.globals.getNode("/controls/pneumatics/switches/ram-air"),
		tempAft: props.globals.getNode("/controls/pneumatics/switches/temp-cabin-aft"),
		tempCockpit: props.globals.getNode("/controls/pneumatics/switches/temp-cockpit"),
		tempFwd: props.globals.getNode("/controls/pneumatics/switches/temp-cabin-fwd"),
		xbleed: props.globals.getNode("/controls/pneumatics/switches/x-bleed"),
	},
	Warnings: {
		prv1Disag: props.globals.getNode("/systems/pneumatics/valves/engine-1-prv-valve-disag"),
		prv2Disag: props.globals.getNode("/systems/pneumatics/valves/engine-2-prv-valve-disag"),
		ovht1: props.globals.getNode("/systems/pneumatics/warnings/ovht-1-mem"),
		ovht2: props.globals.getNode("/systems/pneumatics/warnings/ovht-2-mem"),
		overpress1: props.globals.getNode("/systems/pneumatics/warnings/overpress-1-mem"),
		overpress2: props.globals.getNode("/systems/pneumatics/warnings/overpress-2-mem"),
	},
	Valves: {
		apu: props.globals.getNode("/systems/pneumatics/valves/apu-bleed-valve"),
		crossbleed: props.globals.getNode("/systems/pneumatics/valves/crossbleed-valve"),
		prv1: props.globals.getNode("/systems/pneumatics/valves/engine-1-prv-valve"),
		prv2: props.globals.getNode("/systems/pneumatics/valves/engine-2-prv-valve"),
		pack1: props.globals.getNode("/systems/air-conditioning/valves/flow-control-valve-1"),
		pack2: props.globals.getNode("/systems/air-conditioning/valves/flow-control-valve-2"),
		ramAir: props.globals.getNode("/systems/air-conditioning/valves/ram-air"),
		hotAir: props.globals.getNode("/systems/air-conditioning/valves/hot-air"),
		starter1: props.globals.getNode("/systems/pneumatics/valves/starter-valve-1"),
		starter2: props.globals.getNode("/systems/pneumatics/valves/starter-valve-2"),
		wingLeft: props.globals.getNode("/systems/pneumatics/valves/wing-ice-1"),
		wingRight: props.globals.getNode("/systems/pneumatics/valves/wing-ice-2"),
	},
	pressMode: props.globals.getNode("/systems/pressurization/mode", 1),
	init: func() {
		me.resetFailures();
		me.Switch.apu.setBoolValue(0);
		me.Switch.bleed1.setBoolValue(1);
		me.Switch.bleed2.setBoolValue(1);
		me.Switch.blower.setBoolValue(0);
		me.Switch.cabinFans.setBoolValue(1);
		me.Switch.extract.setBoolValue(0);
		me.Switch.groundAir.setBoolValue(0);
		me.Switch.hotAir.setBoolValue(1);
		me.Switch.pack1.setBoolValue(0);
		me.Switch.pack2.setBoolValue(0);
		me.Switch.packFlow.setValue(1);
		me.Switch.ramAir.setBoolValue(0);
		me.Switch.tempAft.setValue(0.5);
		me.Switch.tempCockpit.setValue(0.5);
		me.Switch.tempFwd.setValue(0.5);
		me.Switch.xbleed.setValue(1);
		
		# Legacy pressurization system
		setprop("/systems/pressurization/mode", "GN");
		setprop("/systems/pressurization/vs", "0");
		setprop("/systems/pressurization/targetvs", "0");
		setprop("/systems/pressurization/vs-norm", "0");
		setprop("/systems/pressurization/auto", 1);
		setprop("/systems/pressurization/deltap", "0");
		setprop("/systems/pressurization/outflowpos", "0");
		setprop("/systems/pressurization/deltap-norm", "0");
		setprop("/systems/pressurization/outflowpos-norm", "0");
		setprop("/systems/pressurization/outflowpos-man", "0.5");
		setprop("/systems/pressurization/outflowpos-man-sw", "0");
		setprop("/systems/pressurization/outflowpos-norm-cmd", "0");
		setprop("/systems/pressurization/cabinalt", pts.Instrumentation.Altimeter.indicatedFt.getValue());
		setprop("/systems/pressurization/targetalt", pts.Instrumentation.Altimeter.indicatedFt.getValue()); 
		setprop("/systems/pressurization/diff-to-target", "0");
		setprop("/systems/pressurization/ditchingpb", 0);
		setprop("/systems/pressurization/targetvs", "0");
			setprop("/systems/pressurization/ambientpsi", 14.7);
			setprop("/systems/pressurization/cabinpsi", 14.7);
		setprop("/systems/pressurization/manvs-cmd", "0");
			var init_alt = pts.Instrumentation.Altimeter.indicatedFt.getValue();
			if (init_alt == nil) init_alt = 0;
			setprop("/systems/pressurization/landing-elev", init_alt);
		setprop("/systems/pressurization/pack-1-out-temp", 0);
		setprop("/systems/pressurization/pack-2-out-temp", 0);
		setprop("/systems/pressurization/pack-1-bypass", 0);
		setprop("/systems/pressurization/pack-2-bypass", 0);
		setprop("/systems/pressurization/pack-1-flow", 0);
		setprop("/systems/pressurization/pack-2-flow", 0);
		setprop("/systems/pressurization/pack-1-comp-out-temp", 0);
		setprop("/systems/pressurization/pack-2-comp-out-temp", 0);
		setprop("/systems/pressurization/pack-1-valve", 0);
		setprop("/systems/pressurization/pack-2-valve", 0);
		#setprop("/systems/ventilation/cabin/fans", 0); # aircon fans
		#setprop("/systems/ventilation/avionics/extractvalve", "0");
		#setprop("/systems/ventilation/avionics/inletvalve", "0");
		setprop("/controls/oxygen/passenger-mask-deploy-man", 0);
		setprop("/controls/oxygen/passenger-mask-reset", 0); # this is the TMR RESET pb on the maintenance panel, needs 3D model
	},
	resetFailures: func() {
		me.Fail.apu.setBoolValue(0);
		me.Fail.bleed1.setBoolValue(0);
		me.Fail.bleed2.setBoolValue(0);
		me.Fail.cabinFans.setBoolValue(0);
		me.Fail.hotAir.setBoolValue(0);
		me.Fail.hp1Valve.setBoolValue(0);
		me.Fail.hp2Valve.setBoolValue(0);
		me.Fail.pack1.setBoolValue(0);
		me.Fail.pack2.setBoolValue(0);
		me.Fail.ramAir.setBoolValue(0);
		me.Fail.trimValveCockpit.setBoolValue(0);
		me.Fail.trimValveAft.setBoolValue(0);
		me.Fail.trimValveFwd.setBoolValue(0);
		me.Fail.xbleed.setBoolValue(0);
	},
	loop: func(notification) {
		wowl = notification.gear1Wow;
		wowr = notification.gear2Wow;
		var on_ground = (wowl or wowr);
		
		# Legacy pressurization
		cabinalt = getprop("/systems/pressurization/cabinalt");
		targetalt = getprop("/systems/pressurization/targetalt");
		ambient = getprop("/systems/pressurization/ambientpsi");
		cabinpsi = getprop("/systems/pressurization/cabinpsi");
		state1 = systems.FADEC.detentText[0].getValue();
		state2 = systems.FADEC.detentText[1].getValue();
		pressmode = getprop("/systems/pressurization/mode");
		vs_norm = getprop("/systems/pressurization/vs-norm");
		if (vs_norm == nil) vs_norm = 0;
		manvs = getprop("/systems/pressurization/manvs-cmd");
		if (manvs == nil) manvs = 0;
		pause = getprop("/sim/freeze/master");
		auto = getprop("/systems/pressurization/auto");
		if (auto == nil) auto = 1;
		speed = getprop("/velocities/groundspeed-kt");
		if (speed == nil) speed = 0;
		ditch = getprop("/systems/pressurization/ditchingpb");
		outflowpos = getprop("/systems/pressurization/outflowpos");
		targetvs = getprop("/systems/pressurization/targetvs");
		if (targetvs == nil) targetvs = 0;
		vs_cmd = getprop("/systems/pressurization/vs");
		if (vs_cmd == nil) vs_cmd = targetvs;
		var now = getprop("/sim/time/elapsed-sec");
		var dt = getprop("/sim/time/delta-sec");
		if (now != nil) {
			if (!pause and last_press_elapsed != nil and now > last_press_elapsed) {
				dt = now - last_press_elapsed;
			}
			last_press_elapsed = now;
		}
		if (cabinalt_bootstrap_t0 == nil and now != nil) cabinalt_bootstrap_t0 = now;
		if (dt == nil) dt = 0.1;
		var alt_ind = getprop("/instrumentation/altimeter/indicated-altitude-ft");
		if (alt_ind == nil) alt_ind = cabinalt;
		if (alt_ind == nil) alt_ind = 0;
		var alt_press = getprop("/instrumentation/altimeter/pressure-alt-ft");
		if (alt_press == nil) alt_press = alt_ind;
		var gps_alt = getprop("/instrumentation/gps/indicated-altitude-ft");
		var ground_elev = getprop("/position/ground-elev-ft");
		var alt_ground = alt_ind;
		var eq_targetalt = alt_press;
		if (eq_targetalt == nil) eq_targetalt = alt_ind;
		if (eq_targetalt == nil) eq_targetalt = 0;
		var door_l1 = getprop("/sim/model/door-positions/doorl1/position-norm");
		if (door_l1 == nil) door_l1 = 0;
		var door_l4 = getprop("/sim/model/door-positions/doorl4/position-norm");
		if (door_l4 == nil) door_l4 = 0;
		var door_r1 = getprop("/sim/model/door-positions/doorr1/position-norm");
		if (door_r1 == nil) door_r1 = 0;
		var door_r4 = getprop("/sim/model/door-positions/doorr4/position-norm");
		if (door_r4 == nil) door_r4 = 0;
		var doors_open = 0;
		if (door_l1 > 0.001 or door_l4 > 0.001 or door_r1 > 0.001 or door_r4 > 0.001) doors_open = 1;
		setprop("/systems/pressurization/doors-open", doors_open);
		var pack_factor = getprop("/systems/air-conditioning/packs/pack-factor");
		if (pack_factor == nil) pack_factor = 0;
		if (press_avail_drop_s == nil) press_avail_drop_s = 0;
		var press_avail_inst = 0;
		if (pack_factor != 0) press_avail_inst = 1;
		if (press_avail_inst == 1) {
			press_avail_latched = 1;
			press_avail_drop_s = 0;
		} else if (!on_ground) {
			press_avail_drop_s += dt;
			if (press_avail_drop_s >= 1.0) press_avail_latched = 0;
		} else {
			press_avail_latched = 0;
			press_avail_drop_s = 0;
		}
		setprop("/systems/pressurization/press-avail", press_avail_latched);
		var eq_mode = 0;
		if (on_ground and !pause) eq_mode = 1;
		setprop("/systems/pressurization/eq-mode", eq_mode);
		setprop("/systems/pressurization/eq-targetalt", eq_targetalt);
		if (cabinalt_bootstrap_done == 0 and on_ground and !pause and now != nil and cabinalt_bootstrap_t0 != nil and (now - cabinalt_bootstrap_t0) <= 30) {
			var ref = eq_targetalt;
			var pos_alt = getprop("/position/altitude-ft");
			if (ref == nil or math.abs(ref) <= 1) ref = ground_elev;
			if (ref == nil or math.abs(ref) <= 1) ref = pos_alt;
			if (ref == nil) ref = 0;
			var sensors_ready = 0;
			if ((ground_elev != nil and math.abs(ground_elev) > 1) or (eq_targetalt != nil and math.abs(eq_targetalt) > 1) or (pos_alt != nil and math.abs(pos_alt) > 1)) {
				sensors_ready = 1;
			}
			var cab = cabinalt;
			if (cab == nil) cab = 0;
			var cab_uninit = (cab < 50);
			var cab_far = (cab < 200 and math.abs(ref - cab) > 500);
			var ref_ok = (ref > -1000 and ref < 20000);
			if (ref_ok and sensors_ready and (cab_uninit or cab_far)) {
				cabinalt = ref;
				targetalt = ref;
				setprop("/systems/pressurization/cabinalt", cabinalt);
				setprop("/systems/pressurization/targetalt", targetalt);
				cabinalt_bootstrap_done = 1;
			}
		}
		setprop("/systems/pressurization/cabinalt-bootstrap-done", cabinalt_bootstrap_done);
		if (gps_alt != nil and gps_alt > -1500 and gps_alt < 20000) {
			var use_gps = 1;
			if (ground_elev != nil) {
				use_gps = 0;
				if (math.abs(gps_alt - ground_elev) <= 300) {
					use_gps = 1;
				}
			}
			if (use_gps == 1) alt_ground = gps_alt;
		}
		var aircraft_vs = getprop("/velocities/vertical-speed-fps");
		if (aircraft_vs == nil) aircraft_vs = 0;
		aircraft_vs *= 60; # fpm
		var landing_elev = getprop("/systems/pressurization/landing-elev");
		if (landing_elev == nil) landing_elev = alt_ind;
		var step = 0;
		var newalt = cabinalt;
		if (pause) {
			dt = 0;
		} else {
			if (dt < 0.01) dt = 0.01;
			if (dt > 0.3) dt = 0.3;
		}
		setprop("/systems/pressurization/dt-used", dt);
		var ambient_prev = ambient;
		if (ambient_prev == nil) ambient_prev = 14.7;
		var p_static = getprop("/systems/static[0]/pressure-inhg");
		if (p_static == nil) p_static = getprop("/environment/pressure-inhg");
		var ambient_calc = nil;
		if (p_static != nil) ambient_calc = p_static * 0.491154;
		ambient = ambient_calc;
		if (ambient == nil) ambient = ambient_prev;
		if (ambient == nil) ambient = 14.7;
		setprop("/systems/pressurization/ambientpsi", ambient);
		if (cabinpsi == nil) cabinpsi = ambient;
		if (cabinalt == nil) {
			cabinalt = alt_press;
			setprop("/systems/pressurization/cabinalt", cabinalt);
		}
		if (targetalt == nil) targetalt = cabinalt;
		
		var targetalt_cmd = getprop("/systems/pressurization/targetalt-cmd");
		if (targetalt_cmd == nil) targetalt_cmd = targetalt;
		setprop("/systems/pressurization/diff-to-target", targetalt - cabinalt); 
		setprop("/systems/pressurization/diff-to-targetalt", targetalt_cmd - cabinalt); 
		setprop("/systems/pressurization/deltap", cabinpsi - ambient); 
	
		if ((pressmode == "GN") and (pressmode != "CL") and (wowl and wowr) and ((state1 == "MCT") or (state1 == "TOGA")) and ((state2 == "MCT") or (state2 == "TOGA"))) {
			setprop("/systems/pressurization/mode", "TO");
		} else if (((!wowl) or (!wowr)) and (speed > 100) and (pressmode == "TO")) {
			setprop("/systems/pressurization/mode", "CL");	
		}
		
		# latch landing elevation: on ground track current altitude, in air prefer FMGC value if sane
		var ldg_prop = getprop("/FMGC/internal/ldg-elev");
		if (on_ground) {
			landing_elev = alt_ground;
			setprop("/systems/pressurization/landing-elev", landing_elev);
		} else if (ldg_prop != nil and ldg_prop != 0 and ldg_prop > -1500 and ldg_prop < 20000) {
			landing_elev = ldg_prop;
			setprop("/systems/pressurization/landing-elev", landing_elev);
		}
		
		var diff = targetalt - cabinalt;
		var commanded_vs = targetvs; # default to schedule
		var active = (!pause) and ((press_avail_latched == 1) or on_ground);
		if (eq_mode == 1 and active) {
			var TAU_MIN = 0.5; # minutes
			var VS_EQ_MAX = 250; # fpm clamp for equalization
			var commanded_vs_eq = diff / TAU_MIN;
			if (commanded_vs_eq > VS_EQ_MAX) commanded_vs_eq = VS_EQ_MAX;
			if (commanded_vs_eq < -VS_EQ_MAX) commanded_vs_eq = -VS_EQ_MAX;
			commanded_vs = commanded_vs_eq;
			if (commanded_vs > VS_MAX) commanded_vs = VS_MAX;
			if (commanded_vs < -VS_MAX) commanded_vs = -VS_MAX;
		} else if (auto and active) {
			var alt_above_ldg = alt_ind - landing_elev;
			if (alt_above_ldg < 0) alt_above_ldg = 0;
			var vs_floor = 750; # fpm for time metric
			var vs_for_time = math.max(math.abs(aircraft_vs), vs_floor);
			var t_go = alt_above_ldg / vs_for_time; # minutes (ft / fpm)
			var VsMax = VS_MAX; # fpm clamp
			var t_need = math.abs(diff) / VsMax;
			var t_min = math.max(dt / 60, 0.02); # minutes
			t_go = math.max(t_go, t_min);
			t_need = math.max(t_need, t_min);
			var t_eff = math.sqrt(t_go * t_need);
			var catchup_rate = 0;
			if (math.abs(diff) > 25) {
				catchup_rate = diff / t_eff;
				if (catchup_rate > VsMax) catchup_rate = VsMax;
				if (catchup_rate < -VsMax) catchup_rate = -VsMax;
			}
			commanded_vs = targetvs + catchup_rate;
			if (commanded_vs > VS_MAX) commanded_vs = VS_MAX;
			if (commanded_vs < -VS_MAX) commanded_vs = -VS_MAX;
		} else if (!auto and active) {
			commanded_vs = manvs;
			if (commanded_vs > VS_MAX) commanded_vs = VS_MAX;
			if (commanded_vs < -VS_MAX) commanded_vs = -VS_MAX;
		}

		if (!active) commanded_vs = 0;
		if (commanded_vs != vs_cmd) {
			setprop("/systems/pressurization/vs", commanded_vs);
			vs_cmd = commanded_vs;
		}
		
		if (auto and active) {
			if (math.abs(diff) > 0.5) {
				var vs_int = getprop("/systems/pressurization/vs-norm");
				if (vs_int == nil) vs_int = vs_cmd;
					step = vs_int * dt / 60;
					newalt = cabinalt + step;
					if ((cabinalt < targetalt and newalt > targetalt) or (cabinalt > targetalt and newalt < targetalt)) {
						newalt = targetalt;
					}
					if (newalt > alt_press) newalt = alt_press; # avoid negative delta-P near landing
					setprop("/systems/pressurization/cabinalt", newalt);
				}
			} else if (!auto and active) {
				var vs_int_man = getprop("/systems/pressurization/vs-norm");
				if (vs_int_man == nil) vs_int_man = vs_cmd;
				step = vs_int_man * dt / 60;
				newalt = cabinalt + step;
				if (newalt > alt_press) newalt = alt_press; # avoid negative delta-P near landing
				setprop("/systems/pressurization/cabinalt", newalt);
			}
		
		#if (ditch and auto) {
			#setprop("/systems/pressurization/outflowpos", "1");
			#setprop("/systems/ventilation/avionics/extractvalve", "1");
			#setprop("/systems/ventilation/avionics/inletvalve", "1");
		#}
	},
};
