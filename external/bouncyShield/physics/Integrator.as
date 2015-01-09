/*
*	
*	Traer v3.0 physics engine, AS3 port
*		original Java code by Jeffrey Traer Bernstein
*		source available at: http://www.cs.princeton.edu/~traer/physics/
*		ported by Arnaud Icard, http://blog.sqrtof5.com, http://github.com/sqrtof5
*	
*/

package external.bouncyShield.physics {
	
	public interface Integrator {
		
		function step(t:Number):void;
		
	}
	
}