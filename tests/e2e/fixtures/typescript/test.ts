// Fixture for LSP perf tests (vtsls attaches here)
export interface Point {
  x: number;
  y: number;
}

export function distance(a: Point, b: Point): number {
  return Math.hypot(a.x - b.x, a.y - b.y);
}

export function translate(p: Point, dx: number, dy: number): Point {
  return { x: p.x + dx, y: p.y + dy };
}

export class Vec implements Point {
  constructor(
    public x: number,
    public y: number,
  ) {}

  length(): number {
    return distance(this, { x: 0, y: 0 });
  }

  add(o: Vec): Vec {
    return new Vec(this.x + o.x, this.y + o.y);
  }
}
