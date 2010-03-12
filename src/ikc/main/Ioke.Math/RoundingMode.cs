namespace Ioke.Math {
    public class RoundingModeS {
        public static RoundingMode valueOf(int mode) {
            switch (mode) {
            case BigDecimal.ROUND_CEILING:
                return RoundingMode.CEILING;
            case BigDecimal.ROUND_DOWN:
                return RoundingMode.DOWN;
            case BigDecimal.ROUND_FLOOR:
                return RoundingMode.FLOOR;
            case BigDecimal.ROUND_HALF_DOWN:
                return RoundingMode.HALF_DOWN;
            case BigDecimal.ROUND_HALF_EVEN:
                return RoundingMode.HALF_EVEN;
            case BigDecimal.ROUND_HALF_UP:
                return RoundingMode.HALF_UP;
            case BigDecimal.ROUND_UNNECESSARY:
                return RoundingMode.UNNECESSARY;
            case BigDecimal.ROUND_UP:
                return RoundingMode.UP;
            default:
                throw new System.ArgumentException("Invalid rounding mode");
            }
        }

        public static int ordinal(RoundingMode mode) {
            switch (mode) {
            case RoundingMode.UP:
                return 0;
            case RoundingMode.DOWN:
                return 1;
            case RoundingMode.CEILING:
                return 2;
            case RoundingMode.FLOOR:
                return 3;
            case RoundingMode.HALF_UP:
                return 4;
            case RoundingMode.HALF_DOWN:
                return 5;
            case RoundingMode.HALF_EVEN:
                return 6;
            case RoundingMode.UNNECESSARY:
                return 7;
            default:
                throw new System.ArgumentException("Invalid rounding mode");
            }
        }
    }

    public enum RoundingMode {
        UP,
        DOWN,
        CEILING,
        FLOOR,
        HALF_UP,
        HALF_DOWN,
        HALF_EVEN,
        UNNECESSARY
    }
}
