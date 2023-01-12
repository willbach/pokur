import Col from '../spacing/Col';
import Loader from './Loader';

import './LoadingOverlay.scss';

const LoadingOverlay = ({
  loading,
  text,
  dismiss,
}: {
  loading: boolean;
  text?: string;
  dismiss?: () => void;
}) => {
  if (!loading) {
    return null;
  }

  return (
    <Col className={`loading-overlay ${dismiss ? 'secondary' : ''}`} onClick={() => dismiss ? dismiss() : null}>
      <Col className={`${text ? 'solid' : ''}`}>
        {!!text && <Col className="loader-text">{text}</Col>}
        <Loader />
        {Boolean(dismiss) && <div className="close" onClick={dismiss}>
          &#215;
        </div>}
      </Col>
    </Col>
  );
};

export default LoadingOverlay;
