var Relation = (function () {
    var _uuid = 0;
    function CloudRelation(opt) {
        'use strict';
        var _DEFAULT = { //默认配置
            node: '',
            width: 600,  //画布宽度
            height: 400,  //画布高度
            nodecirclemax: 30,  //节点半径最大值
            nodecirclemin: 20,  //节点半径最小值
            nodestrokecolor: '#3F3E3E', //节点轮廓颜色 
            nodestrokewidth: 0.5,     //节点轮廓粗细
            nodeTextColor: '#fff',  //节点中字体的颜色,
            nodeTextSize: '14px',  //节点中字体的大小
            nodeTextWeight: '400',  //节点中字体的粗细
            paperFilletStroke: "#fff",//画布圆角轮廓颜色
            paperFilletRadius: 10,//画布圆角半径
            mode: 'edit',   //edit为可移动 view为不可移动
            totallevel: 4,  //总层数
            showstyle: 'tree_H',  //展示风格 doughnut:圆环图；tree_H:横向树形图；tree_V：垂直树形图
            lintwidth: '2px',    // 链接线宽
            lintcolor: '#C6D9EC',    // 链接颜色
            middlePiont: 10,       // 链接线中间点半径
            middlePiontFill: '#BED8EC',       // 链接线中间点填充颜色
            middlePiontStroke: '#C6D9EC',       // 链接线中间点轮廓颜色
            middlePiontText: '?',     // 中间点内文本
            middlePiontTextColor: '#000',       // 中间点内文本颜色
            middlePiontTextSize: '16px',  //节点中字体的大小
            middlePiontTextWeight: '300'  //节点中字体的粗细
        };
        this.cfg = this.merge(_DEFAULT, opt);//给没配置的属性赋予默认值
        this.eventHandlers = [];
        this.cache = {};
        this._init();
    }

    CloudRelation.prototype = {
        constructor: CloudRelation,
        _init: function () {
            var self = this,
                cfg = self.cfg,
                w = cfg.width,
                h = cfg.height;
            node = self.dom().get(cfg.node);
            node.width(w);
            node.height(h);
            var divId = 'cloudSpectrum-' + self._guid();
            node.html('<div id="' + divId + '"></div>');
            self.paper = Raphael(divId, w, h);
            self.paper.rect(0, 0, w, h, cfg.paperFilletRadius).attr({ 'stroke': cfg.paperFilletStroke });
            self.paper.drawTriangle

            //Rapheal插件扩展  （画连接线）
            Raphael.fn.connection = function (obj1, obj2, text, nodeOption) {
                var line;
                if (obj1.line && obj1.from && obj1.to) {
                    line = obj1;
                    obj1 = line.from;
                    obj2 = line.to;
                }
                 
                var bb1 = obj1.getBBox(),
                    bb2 = obj2.getBBox(),
                    po = [{ x: bb1.x + bb1.width / 2, y: bb1.y + bb1.height / 2 },
                          { x: bb2.x + bb2.width / 2, y: bb2.y + bb2.height / 2 },
                          { x: bb2.x + bb2.width / 2, y: bb2.y + bb2.height / 2 }],
                    poc = { x: (po[1].x + po[0].x) / 2, y: (po[1].y + po[0].y) / 2 };
                var path = ["M", po[0].x, po[0].y, "L", po[1].x, po[1].y].join(",");
                if (line && line.line) {
                    line.line.toBack().attr({ path: path });
                    line.lineNode.attr({ x: poc.x, y: poc.y, cx: poc.x, cy: poc.y });
                } else {
                    var color = typeof line == "string" ? line : "#000";
                    return {
                        line: this.path(path).toBack().attr({ 'stroke': cfg.lintcolor, 'stroke-width': cfg.lintwidth, fill: "none",'marker-end': "url(#arrow)" }),
                        from: obj1,
                        to: obj2,
                        lineNode: self.paper.set().push(this.circle(poc.x, poc.y, cfg.middlePiont).attr({ fill: cfg.middlePiontFill, stroke: cfg.middlePiontStroke }), this.text(poc.x, poc.y, text).attr({ 'fill': cfg.middlePiontTextColor, 'font-size': cfg.middlePiontTextSize, 'font-weight': cfg.middlePiontTextWeight, cursor: 'pointer' })),
                        lineOpt: nodeOption               
                    };
                }
            };
        },

        render: function (data) {
            var self = this, cfg = self.cfg, dom = self.dom(), r = self.paper;
            self.connections = [],
            self.shapes = [];      //svg形状集合
            self.flatData = [];    //平面数据(非树状)
            self.data = data;

            self.cache = {};
            self.cache.w = cfg.width;  //画布宽
            self.cache.h = cfg.height;  //画布高

            self.objects = {}; //所有元素缓存

            var shapes = self.shapes, cache = self.cache,
                objs = self.objects, flatData = self.flatData;

            //样式
            var CENTER_STYLE = { 'fill': '#5782C2', 'stroke': '#5782C2' },
                TEXT_STYLE = { 'fill': cfg.nodeTextColor, 'font-size': cfg.nodeTextSize, 'font-weight': cfg.nodeTextWeight };

            //长宽最大数除以层数再除以6，为默认半径  circleRadius=平均每层的高或者宽/6
            var auto = Math.round(Math.max(cache.w, cache.h) / cfg.totallevel),
                circleRadius = Math.round(auto / 6);
            if (circleRadius > cfg.nodecirclemax) {
                circleRadius = cfg.nodecirclemax;  //最大半径
            }
            if (circleRadius < cfg.nodecirclemin) {
                circleRadius = cfg.nodecirclemin;  //最小半径
            }
            self.circleRadius = circleRadius;
            //self.circleRadius = cfg.nodecirclemax;
            var node_y = 0;  //tree_H:横向树形图下的垂直坐标
            var _stack = [], levelStack = [], level = 1;
            _stack.push(data);
            draw(_stack); //绘制

            var ms = false, tar, mar, tardata, delay = false;
            function dragger() {
                if (this.data('setIndex') && this.data('dataIndex') != undefined) {
                    tar = shapes[this.data('setIndex')];
                    tardata = flatData[this.data('dataIndex')];
                    var btar = tar.getBBox();
                    mar = {};
                    ms = true;
                    mar.ox = btar.x;
                    mar.oy = btar.y;
                    mar.cox = btar.x + btar.width / 2;
                    mar.coy = btar.y + btar.height / 2;
                }
            }
            function move(dx, dy) {
                if (ms) {
                    var finalx = mar.cox + dx, finaly = mar.coy + dy;
                    var att = { 'x': finalx, 'y': finaly, 'cx': finalx, 'cy': finaly };
                    if (!delay) {
                        tar.attr(att);
                        tardata.theta = Raphael.rad(Raphael.angle(finalx, finaly, cache.w / 2, cache.h / 2));
                        tardata.radius = self._computeLength(cache.w / 2, cache.h / 2, finalx, finaly);

                        delay = true;
                        setTimeout(function () {
                            delay = false;
                        }, 40);
                    }
                    for (var i = connections.length; i--;) {
                        r.connection(connections[i]);
                    }
                    r.safari();
                }
            }
            function up() {
                if (ms) {
                    ms = false;
                }
            }
            for (var i = 0, ii = shapes.length; i < ii; i++) {
                var color = Raphael.getColor();
                var s = shapes[i];
                s.attr({ cursor: "pointer" });
                if (cfg.mode == 'edit') {
                    s.attr({ cursor: "move" });
                    s.drag(move, dragger, up); //拖动
                }
                (function (sha) {
                    sha.mouseover(function () {
                        sha.stop().animate({ transform: "s1.2 1.2" }, 500, "backOut");
                    }).mouseout(function () {
                        sha.stop().animate({ transform: "" }, 500, "backOut");
                    });

                    if (cfg.mode == 'view') {
                        sha.click(function (e) {
                            var di = this.data('dataIndex');
                            //给节点点击事件添加回传参数  flatDate为节点队列保存节点全部数据
                            self._publish('nodeClick', { x: e.pageX, y: e.pageY, node: flatData[di] });
                        });
                    } else {
                        sha.dblclick(function (e) {
                            var di = this.data('dataIndex');
                            self._publish('nodeClick', { x: e.pageX, y: e.pageY, node: flatData[di] });
                        });
                    }
                })(s);
            }

            var connections = [];
            connect(data, data.childNodes);
            function connect(parent, children, pc) {
                var pobj = objs[parent.id];
                if (children.length > 0) {
                    for (var i = 0; i < children.length; i++) {
                        if (children[i]) {
                            var child = children[i], id = child.id, obj = objs[id], midText = child.middleText;
                            //画连接线
                            connections.push(r.connection(shapes[pobj.index], shapes[obj.index], midText, { pid: parent.id, id: id }));
                            //递归调用
                            connect(child, child.childNodes);
                        }
                    }
                }
            }

            for (var i = 0, ii = connections.length; i < ii; i++) {
                var cs = connections[i];
                (function (cln, opt) {
                    if (cln) {
                        cln.mouseover(function () {
                            cln.stop().animate({ 'transform': "s1.2 1.2" }, 500, "backOut");
                        }).mouseout(function () {
                            cln.stop().animate({ 'transform': "" }, 500, "backOut");
                        });
                        cln.click(function (e) {
                            var clickX = e.pageX;
                            var clickY = e.pageY;
                            self._publish('relationClick', { x: clickX, y: clickY, id: opt.id, parentId: opt.pid });
                        });
                    }
                })(cs.lineNode, cs.lineOpt);
            }

            /**
             * 遍历绘制节点
             *@param 栈(先进后出)
             */
            function draw(stack) {
                var pc = 0;
                while (stack.length > 0) {
                    var node = stack.shift();
                    if (node) {
                        if (node.parent == 0) {//根节点
                            //doughnut:圆环图；
                            if (cfg.showstyle == 'doughnut') {
                                var x = cache.w / 2, y = cache.h / 2;
                            }
                            if (cfg.showstyle == 'tree_H') {//tree_H:横向树形图；
                                var x = 3 * circleRadius, y = 2 * circleRadius;
                            }
                            if (cfg.showstyle == 'tree_V') {//tree_V：垂直树形图
                                var x = cache.w / 2, y = 2 * circleRadius;
                            }
                            //中心点
                            var idx = self.shapes.length;
                            var sha = drawShape(node.shape + '', [x, y], circleRadius * 1.2);
                            sha.attr({ 'fill': node.color, 'stroke': cfg.nodestrokecolor, 'stroke-width': cfg.nodestrokewidth }).data('setIndex', idx);
                            shapes.push(r.set().push(sha, r.text(x, y, node.name).attr(TEXT_STYLE).data('setIndex', idx).data('dataIndex', idx)));
                            objs[node.id] = { 'x': x, 'y': y, 'theta': 0, 'index': 0 };
                            node.theta = 0;
                            node.radius = 0;
                            flatData.push(self.clone(node));
                            //第一层节点
                            if (node.childNodes.length > 0) {
                                levelStack.push(node.childNodes.length);
                            }
                            if (cfg.showstyle == 'tree_H') {//tree_H:横向树形图；

                                drawChildNode({ x: x, y: y }, node.childNodes);
                            }
                            else {
                                drawChildNode({ x: x, y: y }, node.childNodes);
                                stack = stack.concat(node.childNodes);
                                level++;
                            }
                        } else {
                            var pos = objs[node.id];
                            if (pc == levelStack[0]) {
                                levelStack.shift();
                                pc = 0;
                                level++;
                                levelStack.push(node.childNodes.length);
                            } else {
                                if (levelStack[1]) {
                                    levelStack[1] = levelStack[1] + node.childNodes.length;
                                } else {
                                    levelStack[1] = node.childNodes.length;
                                }
                            }
                            drawChildNode(pos, node.childNodes);
                            stack = stack.concat(node.childNodes);
                            pc++;
                        }
                    }
                }
            }

            /**
             * 绘制子节点
             *@param pos 父节点位置对象,x,y坐标和极角
             *@param chidren 子节点数组
             *@param angle 极角
             */
            
            function drawChildNode(pos, children) {
                if (!children.length) {
                    return;
                }
                var len = children.length, averWeight = self._getAverageWeight(children);
                var lev = parseInt(level);//当前的层数
                //doughnut:圆环图；
                if (cfg.showstyle == 'doughnut') {
                    if (pos.theta !== undefined) {
                        var averAngle = Math.PI / len;
                       
                        if (lev > 1) {
                            var p1 = 1.5;
                            //p1为比例系数，数字越大同一层节点间的间隔越大
                            averAngle = Math.PI / lev / parseInt(levelStack[1]) * p1;
                        }
                        var a0 = averAngle * (len - 1) / 2 - pos.theta;
                        for (var i = 0; i < len; i++) {
                            drawSingleNode(children[i], pos, (level * 3.5) * circleRadius, -a0 + i * averAngle);
                        }
                    } else {
                        //第一层子节点场合
                        var averAngle = 2 * Math.PI / len;
                        for (var i = 0; i < len; i++) {
                            drawSingleNode(children[i], pos, (level * 3.5) * circleRadius, i * averAngle);
                        }
                    }
                }
                if (cfg.showstyle == 'tree_V') {//tree_V：垂直树形图
                    var cw;
                    var theta1;
                    if (pos.theta !== undefined) {
                        theta1 = pos.theta;
                        cw = (pos.x - theta1) * 2 / len;
                    }
                    else {
                        theta1 = 0;
                        cw = cfg.width / len;
                    }
                    for (var i = 0; i < len; i++) {
                        //p子节点坐标，cr子节点半径
                        var x1 = (2 * i + 1) * cw / 2 + theta1,
                            y1 = (2 * lev + 1) * 2.2 * circleRadius;
                        drawSingleNode(children[i], [x1,y1], circleRadius * 3, cw * i);
                    }
                }
                if (cfg.showstyle == 'tree_H') {//tree_H:横向树形图；
                    level++;
                    var cw = cfg.width / cfg.totallevel;
                    var x1 = pos.x + cw;
                    node_y = pos.y;
                    for (var i = 0; i < len; i++) {
                        if (i > 0)
                        {
                            node_y = node_y + 2.2 * circleRadius
                        }
                        drawSingleNode(children[i], [x1, node_y], circleRadius * 3, circleRadius);
                        if (children[i].childNodes.length>0) {
                            drawChildNode({ x: x1, y: node_y }, children[i].childNodes);
                        }
                    }
                }
            }

            /**
             * 绘制单个节点
             *@param pos 父节点位置对象
             *@param rad 极径
             *@param angle 极角
             */
            function drawSingleNode(node, pos, rad, angle) {
                if (objs[node.id]) {
                    return;
                }
                var index = flatData.length;
                var p, idx = self.shapes.length;
                if (cfg.mode == 'edit') {
                    if (cfg.showstyle == 'doughnut') {
                        p = self._polarToXY(pos, rad, angle);
                    }
                    else {
                        p = pos;
                    }
                } else {
                    if (cfg.showstyle == 'doughnut') {
                        p = self._polarToXY(pos, node.radius, node.theta);
                    }
                    else {
                        p = pos;
                    }
                }
                var nodeShape;
                if (cfg.mode == 'edit') {
                    nodeShape = drawShape(node.shape + '', p, circleRadius).attr({ 'fill': node.color, 'stroke': cfg.nodestrokecolor, 'stroke-width': cfg.nodestrokewidth }).data('setIndex', idx);
                } else {
                    nodeShape = drawShape(node.shape + '', p, circleRadius).attr({ 'fill': node.color, 'stroke': cfg.nodestrokecolor, 'stroke-width': cfg.nodestrokewidth }).data('setIndex', idx);
                }
                shapes.push(r.set().push(nodeShape, r.text(p[0], p[1], node.name).attr(TEXT_STYLE).data('setIndex', idx).data('dataIndex', index)));
                objs[node.id] = { 'x': p[0], 'y': p[1], 'theta': angle, 'index': idx };
                node.theta = angle;
                node.radius = rad;
                flatData.push(self.clone(node));
            }

            /**
            * 绘制单个图形
            *@param shapeType 画的形状  1-圆形；2-椭圆；3三角形；4-矩形；5-五边形；6-六边形；7-圆角矩形
            *@param p 中心点坐标
            *@param circleRadius 半径或边长
            */
            function drawShape(shapeType, p, circleRadius) {
                var shape;
                switch (shapeType) {
                    case '1': //圆形
                        shape = r.circle(p[0], p[1], circleRadius);
                        break;
                    case '2': // 椭圆
                        shape = r.ellipse(p[0], p[1], circleRadius, circleRadius * 0.6);
                        break;
                    case '3'://三角形
                        shape = drawTriangle(p[0], p[1], circleRadius);
                        break;
                    case '4': //矩形
                        shape = r.rect(p[0] - circleRadius, p[1] - circleRadius, circleRadius * 2, circleRadius * 2);
                        break;
                    case '5':  //五角形
                        shape = drawPentagonal(p[0], p[1], circleRadius);
                        break;
                    case '6':  //六角形
                        shape = drawHexagon(p[0], p[1], circleRadius);
                        break;
                    case '7': //圆角矩形
                        shape = r.rect(p[0] - circleRadius, p[1] - circleRadius, circleRadius * 2, circleRadius * 2, 10);
                        break;
                    default: //默认圆形
                        shape = r.circle(p[0], p[1], circleRadius);
                        break;
                };
                return shape;
            }

            //三角形
            function drawTriangle(x, y, rad) {
                var cos = rad * Math.cos(Math.PI / 3), sin = rad * Math.sin(Math.PI / 3);
                var x1 = x - sin, y1 = y + cos,
                    x2 = x + sin, y2 = y + cos,
                    x3 = x, y3 = y - rad;
                var path = ['M', x1, y1, 'L', x2, y2, 'L', x3, y3].join(' ');
                return r.path(path);
            }
            //五角形
            function drawPentagonal(x, y, rad) {
                var cos36 = rad * Math.cos(36 * Math.PI / 180), sin36 = rad * Math.sin(36 * Math.PI / 180),
                    cos18 = rad * Math.cos(18 * Math.PI / 180), sin18 = rad * Math.sin(18 * Math.PI / 180);
                var x1 = x - sin36, y1 = y + cos36,
                    x2 = x + sin36, y2 = y + cos36,
                    x3 = x + cos18, y3 = y - sin18,
                    x4 = x, y4 = y - rad,
                    x5 = x - cos18, y5 = y - sin18;
                var path = ['M', x1, y1, 'L', x2, y2, 'L', x3, y3, 'L', x4, y4, 'L', x5, y5].join(' ');
                return r.path(path);
            }
            //六角形
            function drawHexagon(x, y, rad) {
                var cos30 = rad * Math.cos(Math.PI / 6), sin30 = rad * Math.sin(Math.PI / 6);
                var x1 = x - sin30, y1 = y + cos30,
                    x2 = x + sin30, y2 = y + cos30,
                    x3 = x + rad, y3 = y,
                    x4 = x + sin30, y4 = y - cos30,
                    x5 = x - sin30, y5 = y - cos30,
                    x6 = x - rad, y6 = y;
                var path = ['M', x1, y1, 'L', x2, y2, 'L', x3, y3, 'L', x4, y4, 'L', x5, y5, 'L', x6, y6].join(' ');
                return r.path(path);
            }
        },

        addNode: function (node, pos, rad, angle){
            var self = this;
            var index = this.flatData.length;
            var p, idx = self.shapes.length;
            //if (this.cfg.mode == 'edit') {
            //    if (this.cfg.showstyle == 'doughnut') {
            //        p = self._polarToXY(pos, rad, angle);
            //    }
            //    else {
            //        p = pos;
            //    }
            //} else {
            //    if (this.cfg.showstyle == 'doughnut') {
            //        p = self._polarToXY(pos, node.radius, node.theta);
            //    }
            //    else {
            //        p = pos;
            //    }
            //}
            //画图形
            var nodeShape;
            nodeShape = this.paper.circle(pos.x, pos.y, this.circleRadius);
            nodeShape.attr({ 'fill': node.color, 'stroke': this.cfg.nodestrokecolor, 'stroke-width': this.cfg.nodestrokewidth }).data('setIndex', idx);
           
            var curShapes = this.paper.set().push(nodeShape, this.paper.text(pos.x, pos.y, node.name).attr({ 'fill': this.cfg.nodeTextColor, 'font-size': this.cfg.nodeTextSize, 'font-weight': this.cfg.nodeTextWeight }).data('setIndex', idx).data('dataIndex', index));
            this.shapes.push(curShapes);

            this.objects[node.id] = { 'x': pos.x, 'y': pos.y, 'theta': angle, 'index': idx };
            node.theta = angle;
            node.radius = rad;
            this.flatData.push(self.clone(node));
            ////拖动效果

            var ms = false, tar, mar, tardata, delay = false;
            function dragger() {
                if (this.data('setIndex') && this.data('dataIndex') != undefined) {
                    tar = self.shapes[this.data('setIndex')];
                    tardata = self.flatData[this.data('dataIndex')];
                    var btar = tar.getBBox();
                    mar = {};
                    ms = true;
                    mar.ox = btar.x;
                    mar.oy = btar.y;
                    mar.cox = btar.x + btar.width / 2;
                    mar.coy = btar.y + btar.height / 2;
                }
            }
            function move(dx, dy) {
                if (ms) {
                    var finalx = mar.cox + dx, finaly = mar.coy + dy;
                    var att = { 'x': finalx, 'y': finaly, 'cx': finalx, 'cy': finaly };
                    if (!delay) {
                        tar.attr(att);
                        tardata.theta = Raphael.rad(Raphael.angle(finalx, finaly, self.cache.w / 2, self.cache.h / 2));
                        tardata.radius = self._computeLength(self.cache.w / 2, self.cache.h / 2, finalx, finaly);

                        delay = true;
                        setTimeout(function () {
                            delay = false;
                        }, 40);
                    }
                    for (var i = self.connections.length; i--;) {
                        self.paper.connection(self.connections[i]);
                    }
                    self.paper.safari();
                }
            }
            function up() {
                if (ms) {
                    ms = false;
                }
            }
            //for (var i = 0, ii = shapes.length; i < ii; i++) {
                var color = Raphael.getColor();
                var s = curShapes;
                s.attr({ cursor: "pointer" });
                if (this.cfg.mode == 'edit') {
                    s.attr({ cursor: "move" });
                    s.drag(move, dragger, up); //拖动
                }
                (function (sha) {
                    sha.mouseover(function () {
                        sha.stop().animate({ transform: "s1.2 1.2" }, 500, "backOut");
                    }).mouseout(function () {
                        sha.stop().animate({ transform: "" }, 500, "backOut");
                    });

                    if (self.cfg.mode == 'view') {
                        sha.click(function (e) {
                            var di = this.data('dataIndex');
                            //给节点点击事件添加回传参数  flatDate为节点队列保存节点全部数据
                            self._publish('nodeClick', { x: e.pageX, y: e.pageY, node: self.flatData[di] });
                        });
                    } else {
                        sha.dblclick(function (e) {
                            var di = this.data('dataIndex');
                            self._publish('nodeClick', { x: e.pageX, y: e.pageY, node: self.flatData[di] });
                        });
                    }
                })(s);
            //}

            

            //画布高度增加
            $("svg").height($("svg").height() + 50);
        },
        //  画连接线
        addConn: function (parent_id, curent_id) {
            var self = this;
            var pobj = this.objects[parent_id], obj = this.objects[curent_id];
            var cs = this.paper.connection(this.shapes[pobj.index], this.shapes[obj.index], '5', { pid: parent_id, id: curent_id });
            this.connections.push(cs);
            (function (cln, opt) {
                if (cln) {
                    cln.mouseover(function () {
                        cln.stop().animate({ 'transform': "s1.2 1.2" }, 500, "backOut");
                    }).mouseout(function () {
                        cln.stop().animate({ 'transform': "" }, 500, "backOut");
                    });
                    cln.click(function (e) {
                        var clickX = e.pageX;
                        var clickY = e.pageY;
                        self._publish('relationClick', { x: clickX, y: clickY, id: opt.id, parentId: opt.pid });
                    });
                }
            })(cs.lineNode, cs.lineOpt);
        },

        save: function () {
            var self = this, result = [];
            for (var i = self.flatData.length - 1; i >= 0; i--) {
                var item = self.flatData[i];
                result.push(item);
            }
            return result;
        },

        preview: function () {
            var self = this, data = self.data, flatData = self.flatData;

            function iterate(nodes) {
                for (var i = 0, ii = nodes.length; i < ii; i++) {
                    var cur = nodes[i];
                    for (var j = 0; j < flatData.length; j++) {
                        if (cur.id == flatData[j].id) {
                            cur.theta = flatData[j].theta;
                            cur.radius = flatData[j].radius;
                        }
                        iterate(cur.childNodes);
                    }
                }
            }
            iterate([data]);
            return data;
        },

        on: function (type, func) {
            var self = this;
            self.eventHandlers[type] = func;
        },

        _publish: function (type, data) {
            var self = this, handlers = self.eventHandlers;
            if (handlers[type]) {
                handlers[type].call(null, data);
            }
        },

        //generate global unique id
        _guid: function () {
            return ++_uuid;
        },

        //极坐标转直角坐标
        _polarToXY: function (pos, rad, angle) {
            var self = this, cache = self.cache, x = cache.w / 2, y = cache.h / 2, radis = self.circleRadius;
            return [x + rad * Math.cos(angle), y + rad * Math.sin(angle)];
        },

        //计算长度
        _computeLength: function (x1, y1, x2, y2) {
            return Math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
        },

        //取得平均权值
        _getAverageWeight: function (arr) {
            if (!arr.length) return 0;
            var sum = 0;
            for (var i = 0, ii = arr.length; i < ii; i++) {
                sum += arr[i].weight;
            }
            return sum / arr.length
        },
        //merge
        merge: function (obj1, obj2) {
            var objClone = new Object();
            for (var key in obj1) {
                objClone[key] = obj1[key];
            }
            for (var key in obj2) {
                objClone[key] = obj2[key];
            }
            return objClone;
        },

        clone: function (obj) {
            var objClone = new Object();
            for (var key in obj) {
                if (Object.prototype.toString.call(obj[key]) == '[object Array]') {
                    objClone[key] = [];
                } else {
                    objClone[key] = obj[key];
                }
            }
            return objClone;
        },

        util: {
            substitute: function (str, obj) {
                if (!(Object.prototype.toString.call(str) === '[object String]')) {
                    return '';
                }
                if (!(Object.prototype.toString.call(obj) === '[object Object]' && 'isPrototypeOf' in obj)) {
                    return str;
                }
                return str.replace(/\{([^{}]+)\}/g, function (match, key) {
                    var value = obj[key];
                    return (value !== undefined) ? '' + value : '';
                });
            }
        },

        //dom封装
        dom: function () {
            function Dom() {
                this.elements = [];
                EventTarget.call(this);
            }

            Dom.prototype = {
                constructor: Dom,
                _events: [],
                get: function (selector, parent) {
                    var element;
                    if (typeof arguments[0] == "string") {
                        element = arguments[0];
                        var prefix = element.slice(0, 1);
                        if (prefix == '#') {
                            element = document.getElementById(element.slice(1));
                            this.elements.push(element);
                        } else {
                            if (document.querySelectorAll) {
                                this.elements.concat(document.querySelectorAll(element, parent.elements));
                            } else {
                                var es = document.body.getElementsByTagName('*');
                                for (var i = 0, j = es.length; i < j; i++) {
                                    if (element.indexOf(es[i].className) != -1) {
                                        this.elements.push(es[i]);
                                    }
                                }
                            }
                        }
                    } else {
                        element = this;
                        this.elements.push(element);
                    }
                    return this;
                },
                each: function (fn) {
                    for (var i = 0, l = this.elements.length; i < l; i++) {
                        fn.call(this, this.elements[i], i);
                    }
                    return this;
                },
                css: function (prop, v) {
                    if (v) {
                        this.each(function (el) {
                            el.style[prop] = v;
                        });
                    } else {
                        return this.elements[0].style[prop];
                    }
                },
                width: function (v) {
                    if (v) {
                        this.elements[0].style.width = v;
                        return this;
                    } else {
                        return this.elements[0].offsetWidth;
                    }
                },
                height: function (v) {
                    if (v) {
                        this.elements[0].style.height = v;
                        return this;
                    } else {
                        return this.elements[0].offsetHeight;
                    }
                },
                html: function (ele) {
                    this.elements[0].innerHTML = ele;
                },
                show: function () {
                    this.each(function (el) {
                        el.style.display = 'block';
                    });
                },
                hide: function () {
                    this.each(function (el) {
                        el.style.display = 'none';
                    });
                },
                ua: {
                    ie: navigator.userAgent.indexOf("IE") < 0 ? false : true,
                    firefox: navigator.userAgent.indexOf("Firefox") < 0 ? false : true,
                    chrome: navigator.userAgent.indexOf("Chrome") < 0 ? false : true
                },
                bind: function (type, func) {
                    var me = this;
                    this._events[type] = func;
                    for (var i = 0, l = this.elements.length; i < l; i++) {
                        var item = this.elements[i];
                        if (item.addEventListener) {
                            item.addEventListener(type, proxyHandler, false);
                        } else if (element.attachEvent) {
                            item.attachEvent('on' + type, proxyHandler);
                        }
                    }
                    function proxyHandler(event) {
                        event = event || window.event;
                        var eve = new _Event(event);
                        eve.type = event.type;
                        eve.target = event.target || event.srcElement;
                        eve.pageX = event.clientX || event.pageX;
                        eve.pageY = event.clientY || event.pageY;
                        eve.button = event.button & 1 ? 1 : (event.button & 2 ? 3 : (event.button & 4 ? 2 : 0));
                        me._events[type].call(me, eve);
                    }
                    function _Event(eve) {
                        this.eve = eve;
                    }
                    return this;
                },
                triggle: function (type, data) {
                    this.each(this._elements, function (i, item) {
                        if (item.fireEvent) {
                            item.fireEvent(type, data);
                        } else if (item.dispatchEvent(event)) {
                            item.dispatchEvent(type, data);
                        }
                    });
                }
            };
            function EventTarget() {
                this.handlers = {};
            }
            EventTarget.prototype = {
                constructor: EventTarget,

                on: function (type, handler) {
                    this.handlers[type] = [];
                },
                fire: function () {
                    if (!event.target) {
                        event.target = this;
                    }
                    if (this.handlers[event.type instanceof Array]) {
                        var handlers = this.handlers[event.type];
                        for (var i = 0, len = handlers.length; i < len; i++) {
                            handlers[i](event);
                        }
                    }
                },
                removeHandler: function (type, handler) {
                    if (this.handlers[type] instanceof Array) {
                        var handlers = this.handlers[type];
                        for (var i = 0, le = handlers.length; i < len; i++) {
                            if (handlers[i] === handler) {
                                break;
                            }
                            handlers.splice(i, 1);
                        }
                    }
                }
            };
            return new Dom();
        }

    };

    return CloudRelation;

})();