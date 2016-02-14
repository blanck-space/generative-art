class IntersectionsAlt {
    IntersectionsAlt(n){
        this.points = [];
        this.numPoints = n;
        this.shapes = {};

        this.depth = Math.min(width, height);

        for(int i = 0; i < n; i++){
            PVector rand = Util.randomPoint3D(-width/2, width/2, -height/2, height/2, -this.depth/2, this.depth/2);
            PVector vel;
            while(vel == null || vel.mag() == 0){
              vel = new PVector(Util.random(-1, 1), Util.random(-1, 1), Util.random(-1, 1));
            }
            vel.div(4);

            this.points.push({
                id: i,
                coord: rand,
                radius: Util.random(50, Math.max(width*height/3200, 100)),
                velocity: vel,
            });
        }

        PVector vel = Util.randomVelocity8();
        vel.div(4);
        this.points.push({
            id: -1,
            coord: new PVector(mouseX-width/2, mouseY-height/2, 0),
            radius: 200,
            velocity: vel,
        });
    }

    void update(){
        // move points
        int depth = this.depth;
        this.points.forEach(function(p){
            if (p.coord.x < -width/2 || p.coord.x > width/2){
                p.velocity.x *= -1;
            }
            if (p.coord.y < -height/2 || p.coord.y > height/2){
                p.velocity.y *= -1;
            }
            if (p.coord.z < -depth/2 || p.coord.z > depth/2){
                p.velocity.z *= -1;
            }

            p.coord.add(p.velocity);
        });

        // update mouse 
        var mouseP = this.points[this.points.length-1];
        mouseP.coord.x = mouseX - width/2;
        mouseP.coord.y = mouseY - height/2;

        this.shapes.forEach(function(s){
            s.color.alpha = s.color.alpha < s.colorMax? (s.color.alpha + s.colorVel) : s.colorMax;
        })
    }

    void draw(){
        translate(0,0, -this.depth);


        pushMatrix();
        background(0);
        noFill();

        translate(width/2, height/2, this.depth/2);
        rotateY(45);
        // rotateX(45);

        // draw axes
        stroke(255, 0, 0, 100);
        line(0, 0, 0, 0, 0, this.depth/2);
        stroke(0, 255, 0, 100);
        line(0, 0, 0, 0, height/2, 0);
        stroke(0, 0, 255, 100);
        line(0, 0, 0, width/2, 0, 0);

        // draw box of bounds
        stroke(255, 100);
        box(width, height, this.depth);
        lights();

        this.drawBodies();

        popMatrix();
    }

    void drawBodies(){
        // draw spheres
        noStroke();
        fill(255, 100);
        for(int i = 0; i < this.points.length; i++){
            pushMatrix()
            var p = this.points[i];
            var r = p.radius;
            var x = p.coord.x;
            var y = p.coord.y;
            translate(x, y, p.coord.z);
            // sphere(r);
            popMatrix();
        }

        this.points.forEach(function(p, j){
            //draw center
            pushMatrix()
            fill(100);
            noStroke();
            translate(p.coord.x, p.coord.y, p.coord.z);
            int c = Math.floor(j/this.points.length*255);
            fill(200);
            sphere(2);
            popMatrix();
            
            var shape;

            if(!(p.id in this.shapes)){
                this.shapes[p.id] = {
                    vertices: [],
                    verticesIds: -1,
                    color: {
                        base: 255,
                        alpha: 0,
                    },
                    colorVel: 1,
                    colorMax: 100,

                }

            } 

            shape = this.shapes[p.id];
            var newVertices = [];
            var newVerticesIds = 0;

            // start point
            newVertices.push(Util.copyVector(p.coord));
            for(int i = 0; i < this.points.length; i++){
                // if intersect
                var o = this.points[i];
                int x1 = p.coord.x;
                int x2 = o.coord.x;
                int y1 = p.coord.y;
                int y2 = o.coord.y;
                int dist = o.coord.dist(p.coord);
                if(dist < Math.max(p.radius, o.radius)){
                    // add points
                    newVertices.push(new PVector(o.coord.x, o.coord.y, o.coord.z));
                    newVerticesIds += o.id;
                }
            }
            // end point
            newVertices.push(Util.copyVector(p.coord));

            // if is new shape, reset opacity
            if(newVertices.length != shape.vertices.length){
                shape.color.alpha =  0;
            }
            shape.vertices = newVertices;
            shape.verticesIds = newVerticesIds;
        }.bind(this));

        // draw shapes
        for(var id in this.shapes){
            var s = this.shapes[id];
            fill(s.color.base, s.color.alpha);
            stroke(255, s.color.alpha*2);

            strokeJoin(MITER);
            // start polygon
            beginShape();
            s.vertices.forEach(function(v){
                vertex(v.x, v.y, v.z);

            });
            endShape();

        }
    }
}