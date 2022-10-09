import * as webglUtils from 'webgl-utils.js';

export default async function render(id: string) {
    const canvas =  <HTMLCanvasElement>document.querySelector("#" + id);
  const gl = canvas.getContext("webgl2");
  if (!gl) {
    return;
  }

  const vs = await (await fetch('glsl/vertex.glsl')).text();
    const fs = await (await fetch('glsl/fragment.glsl')).text();

  // setup GLSL program
  const program = webglUtils.createProgramFromSources(gl, [vs, fs]);

  // look up where the vertex data needs to go.
  const positionAttributeLocation = gl.getAttribLocation(program, "a_position");

  // Create a vertex array object (attribute state)
  const vao = gl.createVertexArray();

  // and make it the one we're currently working with
  gl.bindVertexArray(vao);

  // Create a buffer to put three 2d clip space points in
  const positionBuffer = gl.createBuffer();

  // Bind it to ARRAY_BUFFER (think of it as ARRAY_BUFFER = positionBuffer)
  gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

  // fill it with a 2 triangles that cover clip space
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
    -1, -1,  // first triangle
     1, -1,
    -1,  1,
    -1,  1,  // second triangle
     1, -1,
     1,  1,
  ]), gl.STATIC_DRAW);

  // Turn on the attribute
  gl.enableVertexAttribArray(positionAttributeLocation);

  // Tell the attribute how to get data out of positionBuffer (ARRAY_BUFFER)
  gl.vertexAttribPointer(
      positionAttributeLocation,
      2,          // 2 components per iteration
      gl.FLOAT,   // the data is 32bit floats
      false,      // don't normalize the data
      0,          // 0 = move forward size * sizeof(type) each iteration to get the next position
      0,          // start at the beginning of the buffer
  );

  webglUtils.resizeCanvasToDisplaySize(gl.canvas);

  // Tell it to use our program (pair of shaders)
  gl.useProgram(program);

  // Bind the attribute/buffer set we want.
  gl.bindVertexArray(vao);

  const width = window.innerWidth * window.devicePixelRatio;
    const height = window.innerHeight * window.devicePixelRatio;

    const resLoc = gl.getUniformLocation(program, "u_resolution");
    gl.uniform2fv(resLoc, [width, height]);

    canvas.width = width;
    canvas.height = height;
    gl.viewport(0, 0, width, height);


  // draw 2 triangles
  gl.drawArrays(
      gl.TRIANGLES,
      0,     // offset
      6,     // num vertices to process
  );
    // const canvas = <HTMLCanvasElement>document.getElementById(id);

    // const gl = canvas.getContext('webgl2');
    // if (!gl) {
    //     console.error('В вашем браузере нельзя использовать WebGl2');
    // }

    // const vertex = await (await fetch('glsl/vertex.glsl')).text();
    // const fragment = await (await fetch('glsl/fragment.glsl')).text();

    // function createShader(gl: WebGL2RenderingContext, type: number, source: string) {
    //     const shader = gl.createShader(type);
    //     gl.shaderSource(shader, source);
    //     gl.compileShader(shader);
    //     const success = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    //     if (success) {
    //         return shader;
    //     }
        
    //     console.log(gl.getShaderInfoLog(shader));
    //     gl.deleteShader(shader);
    // }

    // const vertexShader = createShader(gl, gl.VERTEX_SHADER, vertex);
    // const fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, fragment);

    // function createProgram(gl: WebGL2RenderingContext, vertexShader: WebGLShader, fragmentShader: WebGLShader) {
    //     const program = gl.createProgram();
    //     gl.attachShader(program, vertexShader);
    //     gl.attachShader(program, fragmentShader);
    //     gl.linkProgram(program);
    //     const success = gl.getProgramParameter(program, gl.LINK_STATUS);
    //     if (success) {
    //         return program;
    //     }
        
    //     console.log(gl.getProgramInfoLog(program));
    //     gl.deleteProgram(program);
    // }

    // const program = createProgram(gl, vertexShader, fragmentShader);

    // const positionAttributeLocation = gl.getAttribLocation(program, "a_position");
    // // Create a vertex array object (attribute state)
    // const vao = gl.createVertexArray();

    // // and make it the one we're currently working with
    // gl.bindVertexArray(vao);

    // // Create a buffer to put three 2d clip space points in
    // const positionBuffer = gl.createBuffer();

    // // Bind it to ARRAY_BUFFER (think of it as ARRAY_BUFFER = positionBuffer)
    // gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

    // // fill it with a 2 triangles that cover clip space
    // gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
    // -1, -1,  // first triangle
    // 1, -1,
    // -1,  1,
    // -1,  1,  // second triangle
    // 1, -1,
    // 1,  1,
    // ]), gl.STATIC_DRAW);

    // // Turn on the attribute
    // gl.enableVertexAttribArray(positionAttributeLocation);

    // // Tell the attribute how to get data out of positionBuffer (ARRAY_BUFFER)
    // gl.vertexAttribPointer(
    //     positionAttributeLocation,
    //     2,          // 2 components per iteration
    //     gl.FLOAT,   // the data is 32bit floats
    //     false,      // don't normalize the data
    //     0,          // 0 = move forward size * sizeof(type) each iteration to get the next position
    //     0,          // start at the beginning of the buffer
    // );

    // // webglUtils.resizeCanvasToDisplaySize(gl.canvas);

    // // Tell WebGL how to convert from clip space to pixels
    // gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

    // // Tell it to use our program (pair of shaders)
    // gl.useProgram(program);

    // // Bind the attribute/buffer set we want.
    // gl.bindVertexArray(vao);

    // const width = window.innerWidth * window.devicePixelRatio;
    // const height = window.innerHeight * window.devicePixelRatio;

    // const resLoc = gl.getUniformLocation(program, "u_resolution");
    // gl.uniform2fv(resLoc, [width, height]);

    // canvas.width = width;
    // canvas.height = height;
    // gl.viewport(0, 0, width, height);

    // // draw 2 triangles
    // gl.drawArrays(
    //     gl.TRIANGLES,
    //     0,     // offset
    //     6,     // num vertices to process
    // );
}