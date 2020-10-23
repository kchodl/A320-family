var receivedMessagePage = {
	title: nil,
	fontMatrix: [[0, 0, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0]],
	arrowsMatrix: [[0, 0, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0]],
	arrowsColour: [["ack", "ack", "ack", "ack", "ack", "ack"],["ack", "ack", "ack", "ack", "ack", "ack"]],
	L1: [nil, nil, "ack"], # content, title, colour
	L2: [nil, nil, "ack"],
	L3: [nil, nil, "ack"],
	L4: [nil, nil, "ack"],
	L5: [nil, nil, "ack"],
	L6: [nil, nil, "ack"],
	C1: [nil, nil, "ack"],
	C2: [nil, nil, "ack"],
	C3: [nil, nil, "ack"],
	C4: [nil, nil, "ack"],
	C5: [nil, nil, "ack"],
	C6: [nil, nil, "ack"],
	R1: [nil, nil, "ack"],
	R2: [nil, nil, "ack"],
	R3: [nil, nil, "ack"],
	R4: [nil, nil, "ack"],
	R5: [nil, nil, "ack"],
	R6: [nil, nil, "ack"],
	computer: nil,
	size: 0,
	new: func(computer, index) {
		var ap = {parents:[receivedMessagePage]};
		ap.computer = computer;
		ap.curPage = index + 1;
		ReceivedMessagesDatabase.database.vector[ap.curPage - 1].viewed = 1;
		ap._setupPageWithData();
		ap.update();
		return ap;
	},
	del: func() {
		return nil;
	},
	scrollLeft: func() {
		me.curPage -= 1;
		if (me.curPage < 1) {
			me.curPage = ReceivedMessagesDatabase.getSize();
		}
		ReceivedMessagesDatabase.database.vector[me.curPage - 1].viewed = 1;
		me.update();
	},
	scrollRight: func() {
		me.curPage += 1;
		if (me.curPage > ReceivedMessagesDatabase.getSize()) {
			me.curPage = 1;
		}
		ReceivedMessagesDatabase.database.vector[me.curPage - 1].viewed = 1;
		me.update();
	},
	_clearPage: func() {
		me.L1 = [nil, nil, "ack"];
		me.L2 = [nil, nil, "ack"];
		me.L3 = [nil, nil, "ack"];
		me.L4 = [nil, nil, "ack"];
		me.L5 = [nil, nil, "ack"];
		me.C1 = [nil, nil, "ack"];
		me.C2 = [nil, nil, "ack"];
		me.C3 = [nil, nil, "ack"];
		me.C4 = [nil, nil, "ack"];
		me.C5 = [nil, nil, "ack"];
		me.R1 = [nil, nil, "ack"];
		me.R2 = [nil, nil, "ack"];
		me.R3 = [nil, nil, "ack"];
		me.R4 = [nil, nil, "ack"];
		me.R5 = [nil, nil, "ack"];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
	},
	_setupPageWithData: func() {
		me.title = "ACARS MESSAGE";
		me.L6 = [" RETURN", nil, "wht"];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
		me.arrowsColour = [["blu", "blu", "blu", "blu", "blu", "wht"], ["ack", "ack", "ack", "ack", "ack", "ack"]];
		me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	update: func() {
		me._clearPage();
		me.size = ReceivedMessagesDatabase.getSize();
		var message = nil;
		if (me.size >= me.curPage) {
			message = ReceivedMessagesDatabase.database.vector[me.curPage - 1];
			me.L1[1] = message.time;
			me.C1[1] = "VIEWED";
			me.C1[2] = "grn";
			me.R1[1] = me.curPage ~ "/" ~ ReceivedMessagesDatabase.getSize();
			
			me.L1[0] = left(message.body, size(message.body) > 30 ? 30 : size(message.body));
			me.L1[2] = "wht";
			me.L2[2] = "wht";
			me.L3[2] = "wht";
			me.L4[2] = "wht";
			me.L5[2] = "wht";
			if (size(message.body) > 30) {
				me.L2[1] = left(split(me.L1[0], message.body)[1], size(message.body) > 60 ? 30 : size(message.body) - 30);
			}
			if (size(message.body) > 60) {
				me.L2[0] = left(split(me.L2[1], message.body)[1], size(message.body) > 90 ? 30 : size(message.body) - 60);
			}
			if (size(message.body) > 90) {
				me.L3[1] = left(split(me.L2[0], message.body)[1], size(message.body) > 120 ? 30 : size(message.body) - 90);
			}
			if (size(message.body) > 120) {
				me.L3[0] = left(split(me.L3[1], message.body)[1], size(message.body) > 150 ? 30 : size(message.body) - 120);
			}
			if (size(message.body) > 150) {
				me.L4[1] = left(split(me.L3[0], message.body)[1], size(message.body) > 180 ? 30 : size(message.body) - 150);
			}
			if (size(message.body) > 180) {
				me.L4[0] = left(split(me.L4[1], message.body)[1], size(message.body) > 210 ? 30 : size(message.body) - 180);
			}
			if (size(message.body) > 210) {
				me.L5[1] = left(split(me.L4[0], message.body)[1], size(message.body) > 240 ? 30 : size(message.body) - 210);
			}
			if (size(message.body) > 240) {
				me.L5[0] = left(split(me.L5[1], message.body)[1], size(message.body) > 270 ? 30 : size(message.body) - 240);
			}
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
};