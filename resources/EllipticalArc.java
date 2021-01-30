// Copyright (c) 2003-2004, Luc Maisonobe
// All rights reserved.
//
// Redistribution and use in source and binary forms, with
// or without modification, are permitted provided that
// the following conditions are met:
//
//    Redistributions of source code must retain the
//    above copyright notice, this list of conditions and
//    the following disclaimer.
//    Redistributions in binary form must reproduce the
//    above copyright notice, this list of conditions and
//    the following disclaimer in the documentation
//    and/or other materials provided with the
//    distribution.
//    Neither the names of spaceroots.org, spaceroots.com
//    nor the names of their contributors may be used to
//    endorse or promote products derived from this
//    software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
// CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
// PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
// USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
// IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
// USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

package org.spaceroots.sphere.geometry;

import java.awt.Shape;
import java.awt.Rectangle;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.awt.geom.AffineTransform;
import java.awt.geom.PathIterator;
import java.awt.geom.GeneralPath;

/** This class represents an elliptical arc on a 2D plane.

 * <p>It is designed as an implementation of the
 * <code>java.awt.Shape</code> interface and can therefore be drawn
 * easily as any of the more traditional shapes provided by the
 * standard Java API.</p>

 * <p>This class differs from the <code>java.awt.geom.Ellipse2D</code>
 * in the fact it can handles parts of ellipse in addition to full
 * ellipses and it can handle ellipses which are not aligned with the
 * x and y reference axes of the plane. <p>

 * <p>Another improvement is that this class can handle degenerated
 * cases like for example very flat ellipses (semi-minor axis much
 * smaller than semi-major axis) and drawing of very small parts of
 * such ellipses at very high magnification scales. This imply
 * monitoring the drawing approximation error for extremely small
 * values. Such cases occur for example while drawing orbits of comets
 * near the perihelion.</p>

 * <p>When the arc does not cover the complete ellipse, the lines
 * joining the center of the ellipse to the endpoints can optionally
 * be included or not in the outline, hence allowing to use it for
 * pie-charts rendering. If these lines are not included, the curve is
 * not naturally closed.</p>

 * @author L. Maisonobe
 */
public class EllipticalArc
  implements Shape {

  private static final double twoPi = 2 * Math.PI;

  // coefficients for error estimation
  // while using quadratic Bézier curves for approximation
  // 0 < b/a < 1/4
  private static final double[][][] coeffs2Low = new double[][][] {
    {
      {  3.92478,   -13.5822,     -0.233377,    0.0128206   },
      { -1.08814,     0.859987,    0.000362265, 0.000229036 },
      { -0.942512,    0.390456,    0.0080909,   0.00723895  },
      { -0.736228,    0.20998,     0.0129867,   0.0103456   }
    }, {
      { -0.395018,    6.82464,     0.0995293,   0.0122198   },
      { -0.545608,    0.0774863,   0.0267327,   0.0132482   },
      {  0.0534754,  -0.0884167,   0.012595,    0.0343396   },
      {  0.209052,   -0.0599987,  -0.00723897,  0.00789976  }
    }
  };

  // coefficients for error estimation
  // while using quadratic Bézier curves for approximation
  // 1/4 <= b/a <= 1
  private static final double[][][] coeffs2High = new double[][][] {
    {
      {  0.0863805, -11.5595,     -2.68765,     0.181224    },
      {  0.242856,   -1.81073,     1.56876,     1.68544     },
      {  0.233337,   -0.455621,    0.222856,    0.403469    },
      {  0.0612978,  -0.104879,    0.0446799,   0.00867312  }
    }, {
      {  0.028973,    6.68407,     0.171472,    0.0211706   },
      {  0.0307674,  -0.0517815,   0.0216803,  -0.0749348   },
      { -0.0471179,   0.1288,     -0.0781702,   2.0         },
      { -0.0309683,   0.0531557,  -0.0227191,   0.0434511   }
    }
  };

  // safety factor to convert the "best" error approximation
  // into a "max bound" error
  private static final double[] safety2 = new double[] {
    0.02, 2.83, 0.125, 0.01
  };

  // coefficients for error estimation
  // while using cubic Bézier curves for approximation
  // 0 < b/a < 1/4
  private static final double[][][] coeffs3Low = new double[][][] {
    {
      {  3.85268,   -21.229,      -0.330434,    0.0127842  },
      { -1.61486,     0.706564,    0.225945,    0.263682   },
      { -0.910164,    0.388383,    0.00551445,  0.00671814 },
      { -0.630184,    0.192402,    0.0098871,   0.0102527  }
    }, {
      { -0.162211,    9.94329,     0.13723,     0.0124084  },
      { -0.253135,    0.00187735,  0.0230286,   0.01264    },
      { -0.0695069,  -0.0437594,   0.0120636,   0.0163087  },
      { -0.0328856,  -0.00926032, -0.00173573,  0.00527385 }
    }
  };

  // coefficients for error estimation
  // while using cubic Bézier curves for approximation
  // 1/4 <= b/a <= 1
  private static final double[][][] coeffs3High = new double[][][] {
    {
      {  0.0899116, -19.2349,     -4.11711,     0.183362   },
      {  0.138148,   -1.45804,     1.32044,     1.38474    },
      {  0.230903,   -0.450262,    0.219963,    0.414038   },
      {  0.0590565,  -0.101062,    0.0430592,   0.0204699  }
    }, {
      {  0.0164649,   9.89394,     0.0919496,   0.00760802 },
      {  0.0191603,  -0.0322058,   0.0134667,  -0.0825018  },
      {  0.0156192,  -0.017535,    0.00326508, -0.228157   },
      { -0.0236752,   0.0405821,  -0.0173086,   0.176187   }
    }
  };

  // safety factor to convert the "best" error approximation
  // into a "max bound" error
  private static final double[] safety3 = new double[] {
    0.001, 4.98, 0.207, 0.0067
  };

  /** Abscissa of the center of the ellipse. */
  protected double cx;

  /** Ordinate of the center of the ellipse. */
  protected double cy;

  /** Semi-major axis. */
  protected double a;

  /** Semi-minor axis. */
  protected double b;

  /** Orientation of the major axis with respect to the x axis. */
  protected double theta;
  private   double cosTheta;
  private   double sinTheta;

  /** Start angle of the arc. */
  protected double eta1;

  /** End angle of the arc. */
  protected double eta2;

  /** Abscissa of the start point. */
  protected double x1;

  /** Ordinate of the start point. */
  protected double y1;

  /** Abscissa of the end point. */
  protected double x2;

  /** Ordinate of the end point. */
  protected double y2;

  /** Abscissa of the first focus. */
  protected double xF1;

  /** Ordinate of the first focus. */
  protected double yF1;

  /** Abscissa of the second focus. */
  protected double xF2;

  /** Ordinate of the second focus. */
  protected double yF2;

  /** Abscissa of the leftmost point of the arc. */
  private double xLeft;

  /** Ordinate of the highest point of the arc. */
  private double yUp;

  /** Horizontal width of the arc. */
  private double width;

  /** Vertical height of the arc. */
  private double height;

  /** Indicator for center to endpoints line inclusion. */
  protected boolean isPieSlice;

  /** Maximal degree for Bézier curve approximation. */
  private int maxDegree;

  /** Default flatness for Bézier curve approximation. */
  private double defaultFlatness;

  protected double f;
  protected double e2;
  protected double g;
  protected double g2;

  /** Simple constructor.
   * Build an elliptical arc composed of the full unit circle centered
   * on origin
   */
  public EllipticalArc() {

    cx         = 0;
    cy         = 0;
    a          = 1;
    b          = 1;
    theta      = 0;
    eta1       = 0;
    eta2       = 2 * Math.PI;
    cosTheta   = 1;
    sinTheta   = 0;
    isPieSlice = false;
    maxDegree  = 3;
    defaultFlatness = 0.5; // half a pixel

    computeFocii();
    computeEndPoints();
    computeBounds();
    computeDerivedFlatnessParameters();

  }

  /** Build an elliptical arc from its canonical geometrical elements.
   * @param center center of the ellipse
   * @param a semi-major axis
   * @param b semi-minor axis
   * @param theta orientation of the major axis with respect to the x axis
   * @param lambda1 start angle of the arc
   * @param lambda2 end angle of the arc
   * @param isPieSlice if true, the lines between the center of the ellipse
   * and the endpoints are part of the shape (it is pie slice like)
   */
  public EllipticalArc(Point2D.Double center, double a, double b,
                       double theta, double lambda1, double lambda2,
                       boolean isPieSlice) {
    this(center.x, center.y, a, b, theta, lambda1, lambda2, isPieSlice);
  }

  /** Build an elliptical arc from its canonical geometrical elements.
   * @param cx abscissa of the center of the ellipse
   * @param cy ordinate of the center of the ellipse
   * @param a semi-major axis
   * @param b semi-minor axis
   * @param theta orientation of the major axis with respect to the x axis
   * @param lambda1 start angle of the arc
   * @param lambda2 end angle of the arc
   * @param isPieSlice if true, the lines between the center of the ellipse
   * and the endpoints are part of the shape (it is pie slice like)
   */
  public EllipticalArc(double cx, double cy, double a, double b,
                       double theta, double lambda1, double lambda2,
                       boolean isPieSlice) {

    this.cx         = cx;
    this.cy         = cy;
    this.a          = a;
    this.b          = b;
    this.theta      = theta;
    this.isPieSlice = isPieSlice;

    eta1       = Math.atan2(Math.sin(lambda1) / b,
                            Math.cos(lambda1) / a);
    eta2       = Math.atan2(Math.sin(lambda2) / b,
                            Math.cos(lambda2) / a);
    cosTheta   = Math.cos(theta);
    sinTheta   = Math.sin(theta);
    maxDegree  = 3;
    defaultFlatness = 0.5; // half a pixel

    // make sure we have eta1 <= eta2 <= eta1 + 2 PI
    eta2 -= twoPi * Math.floor((eta2 - eta1) / twoPi);

    // the preceding correction fails if we have exactly et2 - eta1 = 2 PI
    // it reduces the interval to zero length
    if ((lambda2 - lambda1 > Math.PI) && (eta2 - eta1 < Math.PI)) {
      eta2 += 2 * Math.PI;
    }

    computeFocii();
    computeEndPoints();
    computeBounds();
    computeDerivedFlatnessParameters();

  }

  /** Build a full ellipse from its canonical geometrical elements.
   * @param center center of the ellipse
   * @param a semi-major axis
   * @param b semi-minor axis
   * @param theta orientation of the major axis with respect to the x axis
   */
  public EllipticalArc(Point2D.Double center,
                       double a, double b, double theta) {
    this(center.x, center.y, a, b, theta);
  }

  /** Build a full ellipse from its canonical geometrical elements.
   * @param cx abscissa of the center of the ellipse
   * @param cy ordinate of the center of the ellipse
   * @param a semi-major axis
   * @param b semi-minor axis
   * @param theta orientation of the major axis with respect to the x axis
   */
  public EllipticalArc(double cx, double cy, double a, double b,
                       double theta) {

    this.cx         = cx;
    this.cy         = cy;
    this.a          = a;
    this.b          = b;
    this.theta      = theta;
    this.isPieSlice = false;

    eta1      = 0;
    eta2      = 2 * Math.PI;
    cosTheta  = Math.cos(theta);
    sinTheta  = Math.sin(theta);
    maxDegree = 3;
    defaultFlatness = 0.5; // half a pixel

    computeFocii();
    computeEndPoints();
    computeBounds();
    computeDerivedFlatnessParameters();

  }

  /** Set the maximal degree allowed for Bézier curve approximation.
   * @param maxDegree maximal allowed degree (must be between 1 and 3)
   * @exception IllegalArgumentException if maxDegree is not between 1 and 3
   */
  public void setMaxDegree(int maxDegree) {
    if ((maxDegree < 1) || (maxDegree > 3)) {
      throw new IllegalArgumentException("maxDegree must be between 1 and 3");
    }
    this.maxDegree = maxDegree;
  }

  /** Set the default flatness for Bézier curve approximation.
   * @param defaultFlatness default flatness (must be greater than 1.0e-10)
   * @exception IllegalArgumentException if defaultFlatness is lower
   * than 1.0e-10
   */
  public void setDefaultFlatness(double defaultFlatness) {
    if (defaultFlatness < 1.0e-10) {
      throw new IllegalArgumentException("defaultFlatness must be"
                                         + " greater than 1.0e-10");
    }
    this.defaultFlatness = defaultFlatness;
  }

  /** Compute the locations of the focii. */
  private void computeFocii() {

    double d  = Math.sqrt(a * a - b * b);
    double dx = d * cosTheta;
    double dy = d * sinTheta;

    xF1 = cx - dx;
    yF1 = cy - dy;
    xF2 = cx + dx;
    yF2 = cy + dy;

  }

  /** Compute the locations of the endpoints. */
  private void computeEndPoints() {

    // start point
    double aCosEta1 = a * Math.cos(eta1);
    double bSinEta1 = b * Math.sin(eta1);
    x1 = cx + aCosEta1 * cosTheta - bSinEta1 * sinTheta;
    y1 = cy + aCosEta1 * sinTheta + bSinEta1 * cosTheta;

    // end point
    double aCosEta2 = a * Math.cos(eta2);
    double bSinEta2 = b * Math.sin(eta2);
    x2 = cx + aCosEta2 * cosTheta - bSinEta2 * sinTheta;
    y2 = cy + aCosEta2 * sinTheta + bSinEta2 * cosTheta;

  }

  /** Compute the bounding box. */
  private void computeBounds() {

    double bOnA = b / a;
    double etaXMin, etaXMax, etaYMin, etaYMax;
    if (Math.abs(sinTheta) < 0.1) {
      double tanTheta = sinTheta / cosTheta;
      if (cosTheta < 0) {
        etaXMin = -Math.atan(tanTheta * bOnA);
        etaXMax = etaXMin + Math.PI;
        etaYMin = 0.5 * Math.PI - Math.atan(tanTheta / bOnA);
        etaYMax = etaYMin + Math.PI;
      } else {
        etaXMax = -Math.atan(tanTheta * bOnA);
        etaXMin = etaXMax - Math.PI;
        etaYMax = 0.5 * Math.PI - Math.atan(tanTheta / bOnA);
        etaYMin = etaYMax - Math.PI;
      }
    } else {
      double invTanTheta = cosTheta / sinTheta;
      if (sinTheta < 0) {
        etaXMax = 0.5 * Math.PI + Math.atan(invTanTheta / bOnA);
        etaXMin = etaXMax - Math.PI;
        etaYMin = Math.atan(invTanTheta * bOnA);
        etaYMax = etaYMin + Math.PI;
      } else {
        etaXMin = 0.5 * Math.PI + Math.atan(invTanTheta / bOnA);
        etaXMax = etaXMin + Math.PI;
        etaYMax = Math.atan(invTanTheta * bOnA);
        etaYMin = etaYMax - Math.PI;
      }
    }

    etaXMin -= twoPi * Math.floor((etaXMin - eta1) / twoPi);
    etaYMin -= twoPi * Math.floor((etaYMin - eta1) / twoPi);
    etaXMax -= twoPi * Math.floor((etaXMax - eta1) / twoPi);
    etaYMax -= twoPi * Math.floor((etaYMax - eta1) / twoPi);

    xLeft = (etaXMin <= eta2)
      ? (cx + a * Math.cos(etaXMin) * cosTheta - b * Math.sin(etaXMin) * sinTheta)
      : Math.min(x1, x2);
    yUp = (etaYMin <= eta2)
      ? (cy + a * Math.cos(etaYMin) * sinTheta + b * Math.sin(etaYMin) * cosTheta)
      : Math.min(y1, y2);
    width = ((etaXMax <= eta2)
             ? (cx + a * Math.cos(etaXMax) * cosTheta - b * Math.sin(etaXMax) * sinTheta)
             : Math.max(x1, x2)) - xLeft;
    height = ((etaYMax <= eta2)
              ? (cy + a * Math.cos(etaYMax) * sinTheta + b * Math.sin(etaYMax) * cosTheta)
              : Math.max(y1, y2)) - yUp;

  }

  private void computeDerivedFlatnessParameters() {
    f   = (a - b) / a;
    e2  = f * (2.0 - f);
    g   = 1.0 - f;
    g2  = g * g;
  }

  /** Compute the value of a rational function.
   * This method handles rational functions where the numerator is
   * quadratic and the denominator is linear
   * @param x absissa for which the value should be computed
   * @param c coefficients array of the rational function
   */
  private static double rationalFunction(double x, double[] c) {
    return (x * (x * c[0] + c[1]) + c[2]) / (x + c[3]);
  }

  /** Estimate the approximation error for a sub-arc of the instance.
   * @param degree degree of the Bézier curve to use (1, 2 or 3)
   * @param tA start angle of the sub-arc
   * @param tB end angle of the sub-arc
   * @return upper bound of the approximation error between the Bézier
   * curve and the real ellipse
   */
  protected double estimateError(int degree, double etaA, double etaB) {

    double eta  = 0.5 * (etaA + etaB);

    if (degree < 2) {

      // start point
      double aCosEtaA  = a * Math.cos(etaA);
      double bSinEtaA  = b * Math.sin(etaA);
      double xA        = cx + aCosEtaA * cosTheta - bSinEtaA * sinTheta;
      double yA        = cy + aCosEtaA * sinTheta + bSinEtaA * cosTheta;

      // end point
      double aCosEtaB  = a * Math.cos(etaB);
      double bSinEtaB  = b * Math.sin(etaB);
      double xB        = cx + aCosEtaB * cosTheta - bSinEtaB * sinTheta;
      double yB        = cy + aCosEtaB * sinTheta + bSinEtaB * cosTheta;

      // maximal error point
      double aCosEta   = a * Math.cos(eta);
      double bSinEta   = b * Math.sin(eta);
      double x         = cx + aCosEta * cosTheta - bSinEta * sinTheta;
      double y         = cy + aCosEta * sinTheta + bSinEta * cosTheta;

      double dx = xB - xA;
      double dy = yB - yA;

      return Math.abs(x * dy - y * dx + xB * yA - xA * yB)
           / Math.sqrt(dx * dx + dy * dy);

    } else {

      double x    = b / a;
      double dEta = etaB - etaA;
      double cos2 = Math.cos(2 * eta);
      double cos4 = Math.cos(4 * eta);
      double cos6 = Math.cos(6 * eta);

      // select the right coeficients set according to degree and b/a
      double[][][] coeffs;
      double[] safety;
      if (degree == 2) {
        coeffs = (x < 0.25) ? coeffs2Low : coeffs2High;
        safety = safety2;
      } else {
        coeffs = (x < 0.25) ? coeffs3Low : coeffs3High;
        safety = safety3;
      }

      double c0 = rationalFunction(x, coeffs[0][0])
         + cos2 * rationalFunction(x, coeffs[0][1])
         + cos4 * rationalFunction(x, coeffs[0][2])
         + cos6 * rationalFunction(x, coeffs[0][3]);

      double c1 = rationalFunction(x, coeffs[1][0])
         + cos2 * rationalFunction(x, coeffs[1][1])
         + cos4 * rationalFunction(x, coeffs[1][2])
         + cos6 * rationalFunction(x, coeffs[1][3]);

      return rationalFunction(x, safety) * a * Math.exp(c0 + c1 * dEta);

    }

  }

  /** Get the elliptical arc point for a given angular parameter.
   * @param lambda angular parameter for which point is desired
   * @param p placeholder where to put the point, if null a new Point
   * well be allocated
   * @return the object p or a new object if p was null, set to the
   * desired elliptical arc point location
   */
  public Point2D.Double pointAt(double lambda, Point2D.Double p) {

    if (p == null) {
      p = new Point2D.Double();
    }

    double eta      = Math.atan2(Math.sin(lambda) / b, Math.cos(lambda) / a);
    double aCosEta  = a * Math.cos(eta);
    double bSinEta  = b * Math.sin(eta);

    p.x = cx + aCosEta * cosTheta - bSinEta * sinTheta;
    p.y = cy + aCosEta * sinTheta + bSinEta * cosTheta;

    return p;

  }

  /** Tests if the specified coordinates are inside the boundary of the Shape.
   * @param x abscissa of the test point
   * @param y ordinate of the test point
   * @return true if the specified coordinates are inside the Shape
   * boundary; false otherwise
   */
  public boolean contains(double x, double y) {

    // position relative to the focii
    double dx1 = x - xF1;
    double dy1 = y - yF1;
    double dx2 = x - xF2;
    double dy2 = y - yF2;
    if ((dx1 * dx1 + dy1 * dy1 + dx2 * dx2 + dy2 * dy2) > (4 * a * a)) {
      // the point is outside of the ellipse
      return false;
    }

    if (isPieSlice) {
      // check the location of the test point with respect to the
      // angular sector counted from the center of the ellipse
      double dxC = x - cx;
      double dyC = y - cy;
      double u   = dxC * cosTheta + dyC * sinTheta;
      double v   = dyC * cosTheta - dxC * sinTheta;
      double eta = Math.atan2(v / b, u / a);
      eta -= twoPi * Math.floor((eta - eta1) / twoPi);
      return (eta <= eta2);
    } else {
      // check the location of the test point with respect to the
      // line joining the start and end points
      double dx = x2 - x1;
      double dy = y2 - y1;
      return ((x * dy - y * dx + x2 * y1 - x1 * y2) >= 0);

    }

  }

  /** Tests if a line segment intersects the arc.
   * @param xA abscissa of the first point of the line segment
   * @param yA ordinate of the first point of the line segment
   * @param xB abscissa of the second point of the line segment
   * @param yB ordinate of the second point of the line segment
   * @return true if the two line segments intersect
   */
  private boolean intersectArc(double xA, double yA,
                               double xB, double yB) {

    double dx = xA - xB;
    double dy = yA - yB;
    double l  = Math.sqrt(dx * dx + dy * dy);
    if (l < (1.0e-10 * a)) {
      // too small line segment, we consider it doesn't intersect anything
      return false;
    }
    double cz = (dx * cosTheta + dy * sinTheta) / l;
    double sz = (dy * cosTheta - dx * sinTheta) / l;

    // express position of the first point in canonical frame
    dx = xA - cx;
    dy = yA - cy;
    double u = dx * cosTheta + dy * sinTheta;
    double v = dy * cosTheta - dx * sinTheta;

    double u2         = u * u;
    double v2         = v * v;
    double g2u2ma2    = g2 * (u2 - a * a);
    double g2u2ma2mv2 = g2u2ma2 - v2;
    double g2u2ma2pv2 = g2u2ma2 + v2;

    // compute intersections with the ellipse along the line
    // as the roots of a 2nd degree polynom : c0 k^2 - 2 c1 k + c2 = 0
    double c0   = 1.0 - e2 * cz * cz;
    double c1   = g2 * u * cz + v * sz;
    double c2   = g2u2ma2pv2;
    double c12  = c1 * c1;
    double c0c2 = c0 * c2;

    if (c12 < c0c2) {
      // the line does not intersect the ellipse at all
      return false;
    }

    double k = (c1 >= 0)
             ? (c1 + Math.sqrt(c12 - c0c2)) / c0
             : c2 / (c1 - Math.sqrt(c12 - c0c2));
    if ((k >= 0) && (k <= l)) {
      double uIntersect = u - k * cz;
      double vIntersect = v - k * sz;
      double eta = Math.atan2(vIntersect / b, uIntersect / a);
      eta -= twoPi * Math.floor((eta - eta1) / twoPi);
      if (eta <= eta2) {
        return true;
      }
    }

    k = c2 / (k * c0);
    if ((k >= 0) && (k <= l)) {
      double uIntersect = u - k * cz;
      double vIntersect = v - k * sz;
      double eta = Math.atan2(vIntersect / b, uIntersect / a);
      eta -= twoPi * Math.floor((eta - eta1) / twoPi);
      if (eta <= eta2) {
        return true;
      }
    }

    return false;

  }

  /** Tests if two line segments intersect.
   * @param x1 abscissa of the first point of the first line segment
   * @param y1 ordinate of the first point of the first line segment
   * @param x2 abscissa of the second point of the first line segment
   * @param y2 ordinate of the second point of the first line segment
   * @param xA abscissa of the first point of the second line segment
   * @param yA ordinate of the first point of the second line segment
   * @param xB abscissa of the second point of the second line segment
   * @param yB ordinate of the second point of the second line segment
   * @return true if the two line segments intersect
   */
  private static boolean intersect(double x1, double y1,
                                   double x2, double y2,
                                   double xA, double yA,
                                   double xB, double yB) {

    // elements of the equation of the (1, 2) line segment
    double dx12 = x2 - x1;
    double dy12 = y2 - y1;
    double k12  = x2 * y1 - x1 * y2;

    // elements of the equation of the (A, B) line segment
    double dxAB = xB - xA;
    double dyAB = yB - yA;
    double kAB  = xB * yA - xA * yB;

    // compute relative positions of endpoints versus line segments
    double pAvs12 = xA * dy12 - yA * dx12 + k12;
    double pBvs12 = xB * dy12 - yB * dx12 + k12;
    double p1vsAB = x1 * dyAB - y1 * dxAB + kAB;
    double p2vsAB = x2 * dyAB - y2 * dxAB + kAB;

    return (pAvs12 * pBvs12 <= 0) && (p1vsAB * p2vsAB <= 0);

  }

  /** Tests if a line segment intersects the outline.
   * @param xA abscissa of the first point of the line segment
   * @param yA ordinate of the first point of the line segment
   * @param xB abscissa of the second point of the line segment
   * @param yB ordinate of the second point of the line segment
   * @return true if the two line segments intersect
   */
  private boolean intersectOutline(double xA, double yA,
                                   double xB, double yB) {

    if (intersectArc(xA, yA, xB, yB)) {
      return true;
    }

    if (isPieSlice) {
      return (intersect(cx, cy, x1, y1, xA, yA, xB, yB)
              || intersect(cx, cy, x2, y2, xA, yA, xB, yB));
    } else {
      return intersect(x1, y1, x2, y2, xA, yA, xB, yB);
    }

  }

  /** Tests if the interior of the Shape entirely contains the
   * specified rectangular area.
   * @param x abscissa of the upper-left corner of the test rectangle
   * @param y ordinate of the upper-left corner of the test rectangle
   * @param w width of the test rectangle
   * @param h height of the test rectangle
   * @return true if the interior of the Shape entirely contains the
   * specified rectangular area; false otherwise
   */
  public boolean contains(double x, double y, double w, double h) {
    double xPlusW = x + w;
    double yPlusH = y + h;
    return (   contains(x, y)
            && contains(xPlusW, y)
            && contains(x, yPlusH)
            && contains(xPlusW, yPlusH)
            && (! intersectOutline(x,      y,      xPlusW, y))
            && (! intersectOutline(xPlusW, y,      xPlusW, yPlusH))
            && (! intersectOutline(xPlusW, yPlusH, x,      yPlusH))
            && (! intersectOutline(x,      yPlusH, x,      y)));
  }

  /** Tests if a specified Point2D is inside the boundary of the Shape.
   * @param p test point
   * @return true if the specified point is inside the Shape
   * boundary; false otherwise
   */
  public boolean contains(Point2D p) {
    return contains(p.getX(), p.getY());
  }

  /** Tests if the interior of the Shape entirely contains the
   * specified Rectangle2D.
   * @param r test rectangle
   * @return true if the interior of the Shape entirely contains the
   * specified rectangular area; false otherwise
   */
  public boolean contains(Rectangle2D r) {
    return contains(r.getX(), r.getY(), r.getWidth(), r.getHeight());
  }

  /** Returns an integer Rectangle that completely encloses the Shape.
   */
  public Rectangle getBounds() {
    int xMin = (int) Math.rint(xLeft - 0.5);
    int yMin = (int) Math.rint(yUp   - 0.5);
    int xMax = (int) Math.rint(xLeft + width  + 0.5);
    int yMax = (int) Math.rint(yUp   + height + 0.5);
    return new Rectangle(xMin, yMin, xMax - xMin, yMax - yMin);
  }

  /** Returns a high precision and more accurate bounding box of the
   * Shape than the getBounds method.
   */
  public Rectangle2D getBounds2D() {
    return new Rectangle2D.Double(xLeft, yUp, width, height);
  }

  /** Build an approximation of the instance outline.
   * @param degree degree of the Bézier curve to use
   * @param threshold acceptable error
   * @param at affine transformation to apply
   * @return a path iterator
   */
  private PathIterator buildPathIterator(int degree, double threshold,
                                         AffineTransform at) {

    // find the number of Bézier curves needed
    boolean found = false;
    int n = 1;
    while ((! found) && (n < 1024)) {
      double dEta = (eta2 - eta1) / n;
      if (dEta <= 0.5 * Math.PI) {
        double etaB = eta1;
        found = true;
        for (int i = 0; found && (i < n); ++i) {
          double etaA = etaB;
          etaB += dEta;
          found = (estimateError(degree, etaA, etaB) <= threshold);
        }
      }
      n = n << 1;
    }

    GeneralPath path = new GeneralPath(PathIterator.WIND_EVEN_ODD);
    double dEta = (eta2 - eta1) / n;
    double etaB = eta1;

    double cosEtaB  = Math.cos(etaB);
    double sinEtaB  = Math.sin(etaB);
    double aCosEtaB = a * cosEtaB;
    double bSinEtaB = b * sinEtaB;
    double aSinEtaB = a * sinEtaB;
    double bCosEtaB = b * cosEtaB;
    double xB       = cx + aCosEtaB * cosTheta - bSinEtaB * sinTheta;
    double yB       = cy + aCosEtaB * sinTheta + bSinEtaB * cosTheta;
    double xBDot    = -aSinEtaB * cosTheta - bCosEtaB * sinTheta;
    double yBDot    = -aSinEtaB * sinTheta + bCosEtaB * cosTheta;

    if (isPieSlice) {
      path.moveTo((float) cx, (float) cy);
      path.lineTo((float) xB, (float) yB);
    } else {
      path.moveTo((float) xB, (float) yB);
    }

    double t     = Math.tan(0.5 * dEta);
    double alpha = Math.sin(dEta) * (Math.sqrt(4 + 3 * t * t) - 1) / 3;

    for (int i = 0; i < n; ++i) {

      double etaA  = etaB;
      double xA    = xB;
      double yA    = yB;
      double xADot = xBDot;
      double yADot = yBDot;

      etaB    += dEta;
      cosEtaB  = Math.cos(etaB);
      sinEtaB  = Math.sin(etaB);
      aCosEtaB = a * cosEtaB;
      bSinEtaB = b * sinEtaB;
      aSinEtaB = a * sinEtaB;
      bCosEtaB = b * cosEtaB;
      xB       = cx + aCosEtaB * cosTheta - bSinEtaB * sinTheta;
      yB       = cy + aCosEtaB * sinTheta + bSinEtaB * cosTheta;
      xBDot    = -aSinEtaB * cosTheta - bCosEtaB * sinTheta;
      yBDot    = -aSinEtaB * sinTheta + bCosEtaB * cosTheta;

      if (degree == 1) {
        path.lineTo((float) xB, (float) yB);
      } else if (degree == 2) {
        double k = (yBDot * (xB - xA) - xBDot * (yB - yA))
                 / (xADot * yBDot - yADot * xBDot);
        path.quadTo((float) (xA + k * xADot), (float) (yA + k * yADot),
                    (float) xB, (float) yB);
      } else {
        path.curveTo((float) (xA + alpha * xADot), (float) (yA + alpha * yADot),
                     (float) (xB - alpha * xBDot), (float) (yB - alpha * yBDot),
                     (float) xB,                   (float) yB);
      }

    }

    if (isPieSlice) {
      path.closePath();
    }

    return path.getPathIterator(at);

  }

  /** Returns an iterator object that iterates along the Shape
   * boundary and provides access to the geometry of the Shape
   * outline.
   */
  public PathIterator getPathIterator(AffineTransform at) {
    return buildPathIterator(maxDegree, defaultFlatness, at);
  }

  /** Returns an iterator object that iterates along the Shape
   * boundary and provides access to a flattened view of the Shape
   * outline geometry.
   */
  public PathIterator getPathIterator(AffineTransform at, double flatness) {
    return buildPathIterator(1, flatness, at);
  }

  /** Tests if the interior of the Shape intersects the interior of a
   * specified rectangular area.
   */
  public boolean intersects(double x, double y, double w, double h) {
    double xPlusW = x + w;
    double yPlusH = y + h;
    return contains(x, y)
        || contains(xPlusW, y)
        || contains(x, yPlusH)
        || contains(xPlusW, yPlusH)
        || intersectOutline(x,      y,      xPlusW, y)
        || intersectOutline(xPlusW, y,      xPlusW, yPlusH)
        || intersectOutline(xPlusW, yPlusH, x,      yPlusH)
        || intersectOutline(x,      yPlusH, x,      y);
  }

  /** Tests if the interior of the Shape intersects the interior of a
   * specified Rectangle2D.
   */
  public boolean intersects(Rectangle2D r) {
    return intersects(r.getX(), r.getY(), r.getWidth(), r.getHeight());
  }

}
