import React from 'react';
import loadingAnimation from '../assets/loading-animation.json'; // Path to your Lottie animation file
import Lottie from 'lottie-react';
import { TypeAnimation } from 'react-type-animation';

interface CommonLoaderProps {
    loadingText?: string; // Optional prop
}

const CommonLoader: React.FC<CommonLoaderProps> = ({ loadingText = "Loading ..." }) => {
    return (
        <div className="flex flex-col items-center justify-center text-center">
            <Lottie
                animationData={loadingAnimation}
                loop={true}
                className="" // Tailwind for width and height
            />

            <TypeAnimation
                sequence={[
                    loadingText, // Types 'One'
                    1000,
                    'Please Wait ....', // Deletes 'One' and types 'Two'
                    2000,
                    () => {
                        console.log('Sequence completed');
                    },
                ]}
                wrapper="span"
                cursor={true}
                repeat={Infinity}
                style={{ fontSize: '2em', display: 'inline-block' }}
            />
        </div>
    );
};

export default CommonLoader;
