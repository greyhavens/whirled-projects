package popcraft.battle.geom {

import com.threerings.util.ArrayUtil;

public class ForceParticleContainer
{
    public function ForceParticleContainer (width :Number, height :Number)
    {
        _cols = Math.ceil(width / BUCKET_SIZE);
        _rows = Math.ceil(height / BUCKET_SIZE);

        _buckets = ArrayUtil.create(_cols * _rows, null);
    }

    internal function addParticle (p :ForceParticle, x :Number, y :Number) :void
    {
        var col :int = x * BUCKET_SIZE_INV;
        var row :int = y * BUCKET_SIZE_INV;
        var index :int = (row * _cols) + col;

        // already in the correct bucket?
        if (p._bucketIdx == index) {
            return;
        }

        // remove from current bucket
        removeParticle(p);

        // and add to the new one
        var oldHead :ForceParticle = _buckets[index];
        if (null != oldHead) {
            oldHead._prev = p;
        }

        _buckets[index] = p;
        p._next = oldHead;
        p._bucketIdx = index;
        p._col = col;
        p._row = row;
    }

    internal function removeParticle (p :ForceParticle) :void
    {
        var index :int = p._bucketIdx;
        if (index >= 0) {
            var prev :ForceParticle = p._prev;
            var next :ForceParticle = p._next;

            if (null == prev) {
                // particle was the head of its bucket list
                _buckets[index] = next;
            } else {
                prev._next = next;
            }

            if (null != next) {
                next._prev = prev;
            }

            p._bucketIdx = -1;
            p._col = -1;
            p._row = -1;
            p._next = null;
            p._prev = null;
        }
    }

    internal function getBucket (col :int, row :int) :ForceParticle
    {
        return (row >= 0 && row < _rows && col >= 0 && col < _cols ? _buckets[(row * _cols) + col] : null);
    }

    protected var _buckets :Array;
    protected var _cols :int;
    protected var _rows :int;

    protected static const BUCKET_SIZE :int = 30;
    protected static const BUCKET_SIZE_INV :Number = 1 / BUCKET_SIZE;

}

}
