import * as React from 'react';
import styles from './canvas.css';
import render from '../../modules/render/render';

const Canvas: React.FC = () => {
    const id = 'canvas';

    React.useEffect(() => {
        render(id);
    });

    return (
        <canvas id={id} className={styles.main}></canvas>
    );
}

export default Canvas;
